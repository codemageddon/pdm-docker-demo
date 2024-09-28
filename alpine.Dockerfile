ARG PDM_VERSION=2.19.1
ARG PYTHON_VERSION=3.12
ARG WORKDIR=/usr/src/app
ARG BASE_DISTRO=alpine

FROM python:${PYTHON_VERSION}-${BASE_DISTRO} AS build
ARG PDM_VERSION
ARG WORKDIR
RUN pip install pdm==${PDM_VERSION}

ENV PDM_CHECK_UPDATE=false \
    PDM_CACHE_DIR=/tmp/pdm-cache

WORKDIR ${WORKDIR}

RUN --mount=type=cache,target=${PDM_CACHE_DIR} \
    --mount=type=bind,source=pdm.lock,target=pdm.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    pdm sync --no-self --prod


FROM python:${PYTHON_VERSION}-${BASE_DISTRO} AS runtime
ARG WORKDIR
WORKDIR ${WORKDIR}
ENV PATH="${WORKDIR}/.venv/bin:${PATH}"

COPY --from=build ${WORKDIR}/.venv ${WORKDIR}/.venv
RUN adduser -S -D -h /nonexistent app
USER app
COPY hello_world ./hello_world
ENTRYPOINT ["python", "hello_world/main.py"]