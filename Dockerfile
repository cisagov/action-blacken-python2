# Official Docker images are in the form library/<app> while non-official
# images are in the form <user>/<app>.
#
# Python 3.14 has changes to the asyncio library that are incompatible with the
# versions of black and click that we need to use.
FROM docker.io/library/python:3.13.12-alpine3.23

# Copy in the pip constraints file that controls the versions installed below
COPY src/requirements-actually-constraints.txt /tmp/constraints.txt

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
        --constraint /tmp/constraints.txt \
        pip \
        setuptools \
    && python3 -m pip install --no-cache-dir --upgrade \
        --constraint /tmp/constraints.txt \
        black \
        click \
        identify \
    && rm /tmp/constraints.txt

COPY src/blacken.py /opt

# Per the GitHub documentation at
# https://docs.github.com/en/actions/tutorials/use-containerized-services/create-a-docker-container-action#accessing-files-created-by-a-container-action
# the default working directory on the runner is mapped to /github/workspace on the
# container.
ENTRYPOINT ["python", "/opt/blacken.py"]
CMD ["--path", "/github/workspace"]
