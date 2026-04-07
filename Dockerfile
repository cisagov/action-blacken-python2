# Official Docker images are in the form library/<app> while non-official
# images are in the form <user>/<app>.
#
# Python 3.14 has changes to the asyncio library that are incompatible with the
# versions of black and click that we need to use.
FROM docker.io/library/python:3.13.12-alpine3.23 AS compile-stage

# Location of the action's application directory
ENV ACTION_BASE="/opt/blacken"

# Location of the virtual environment we will create
ENV VIRTUAL_ENV="${ACTION_BASE}/.venv"

# Work out of /tmp for this stage
WORKDIR /tmp

# Copy in the pip constraints file that controls the versions installed below
COPY src/requirements-actually-constraints.txt constraints.txt

###
# Install the specified versions of pip and setuptools into the system Python
# environment, install the specified versions of black, click, and identify
# into the system Python environment, and then remove the pip constraints file we
# use to specify the versions of the aforementioned packages.
#
# Note that we use the --constraint flag to specify a pip constraints
# file that controls which package versions are installed. Please see
# the documentation for more information:
# https://pip.pypa.io/en/stable/user_guide/#constraints-files
###
RUN python3 -m pip install --no-cache-dir --upgrade \
        --constraint constraints.txt \
        pip \
        setuptools \
    && python3 -m pip install --no-cache-dir --upgrade \
        --constraint constraints.txt \
        pipenv \
    # Manually create the virtual environment
    && python3 -m venv ${VIRTUAL_ENV} \
    # Ensure the core Python packages are installed in the virtual environment
    && ${VIRTUAL_ENV}/bin/python3 -m pip install --no-cache-dir --upgrade \
        --constraint constraints.txt \
        pip \
        setuptools

###
# Install the Python dependencies into the virtual environment.
#
# Note that pipenv will install into a virtual environment if the VIRTUAL_ENV
# environment variable is set.
###
COPY src/Pipfile src/Pipfile.lock ./
RUN python3 -m pipenv install --clear --deploy --extra-pip-args "--no-cache-dir" --verbose


# Official Docker images are in the form library/<app> while non-official
# images are in the form <user>/<app>.
#
# Python 3.14 has changes to the asyncio library that are incompatible with the
# versions of black and click that we need to use.
FROM docker.io/library/python:3.13.12-alpine3.23 AS build-stage

###
# For a list of pre-defined annotation keys and value types see:
# https://github.com/opencontainers/image-spec/blob/master/annotations.md
#
# Note: Additional labels are added by the build workflow.
###
# github@cisa.dhs.gov is a very generic email distribution, and it is
# unlikely that anyone on that distribution is familiar with the
# particulars of your repository.  It is therefore *strongly*
# suggested that you use an email address here that is specific to the
# person or group that maintains this repository; for example:
# LABEL org.opencontainers.image.authors="vm-dev@gwe.cisa.dhs.gov"
LABEL org.opencontainers.image.authors="github@cisa.dhs.gov"
LABEL org.opencontainers.image.vendor="Cybersecurity and Infrastructure Security Agency"

# Location of the action's application directory
ENV ACTION_BASE="/opt/blacken"

# Location of the virtual environment we will create
ENV VIRTUAL_ENV="${ACTION_BASE}/.venv"

###
# Copy in the Python virtual environment created in compile-stage, symlink the
# Python binary in the venv to the system-wide Python, and add the venv to the PATH.
#
# Note that we symlink the Python binary in the venv to the system-wide Python so that
# any calls to `python3` will use our virtual environment. We are using short flags
# because the ln binary in Alpine Linux does not support long flags. The -f instructs
# ln to remove the existing file and the -s instructs ln to create a symbolic link.
###
COPY --from=compile-stage ${VIRTUAL_ENV} ${VIRTUAL_ENV}
ENV PATH="${VIRTUAL_ENV}/bin:$PATH"

# Copy in the core action functionality
COPY src/blacken.py /opt/blacken/

# Per the GitHub documentation at
# https://docs.github.com/en/actions/tutorials/use-containerized-services/create-a-docker-container-action#accessing-files-created-by-a-container-action
# the default working directory on the runner is mapped to /github/workspace on the
# container.
ENTRYPOINT ["python", "/opt/blacken/blacken.py"]
CMD ["--path", "/github/workspace"]
