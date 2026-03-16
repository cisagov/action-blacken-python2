# Official Docker images are in the form library/<app> while non-official
# images are in the form <user>/<app>.
#
# Python 3.14 has changes to the asyncio library that are incompatible with the
# versions of black and click that we need to use.
FROM docker.io/library/python:3.14.3-alpine3.22

###
# Versions of the Python packages installed directly
#
# This version of black is the last version to support formatting Python 2 code.
# This version of click is the last version compatible with the version of black
# we need to use.
###
ENV PYTHON_BLACK_VERSION=21.12b0
ENV PYTHON_CLICK_VERSION=8.0.4
ENV PYTHON_PIP_VERSION=25.2
ENV PYTHON_SETUPTOOLS_VERSION=80.9.0

###
# Install the specified versions of pip and setuptools into the system
# Python environment; install the specified versions of black and
# click into the system Python environment.
###
RUN python3 -m pip install --no-cache-dir --upgrade \
        pip==${PYTHON_PIP_VERSION} \
        setuptools==${PYTHON_SETUPTOOLS_VERSION} \
    && python3 -m pip install --no-cache-dir --upgrade \
        black==${PYTHON_BLACK_VERSION} \
        click==${PYTHON_CLICK_VERSION}

# Per the GitHub documentation at
# https://docs.github.com/en/actions/tutorials/use-containerized-services/create-a-docker-container-action#accessing-files-created-by-a-container-action
# the default working directory on the runner is mapped to /github/workspace on the
# container.
CMD ["black", "--fast", "/github/workspace"]
