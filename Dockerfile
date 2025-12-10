FROM python:3.11-slim

# Install system dependencies, Poetry, STAR, and Samtools
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       curl \
       libpq-dev \
       libffi-dev \
       libssl-dev \
       git \
       gcc \
       wget \
       unzip \
       zlib1g-dev \
       libbz2-dev \
       liblzma-dev \
       libcurl4-gnutls-dev \
       libncurses5-dev \
    && wget https://github.com/alexdobin/STAR/archive/refs/tags/2.7.10b.zip \
    && unzip 2.7.10b.zip \
    && cd STAR-2.7.10b/source \
    && make STAR \
    && mv STAR /usr/local/bin/ \
    && mkdir -p /app \
    && cd /app \
    && wget https://github.com/samtools/samtools/releases/download/1.17/samtools-1.17.tar.bz2 \
    && tar -xjf samtools-1.17.tar.bz2 \
    && cd samtools-1.17 \
    && ./configure \
    && make \
    && make install \
    && cd /app \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 2.7.10b.zip STAR-2.7.10b samtools-1.17 samtools-1.17.tar.bz2

RUN mkdir /usr/src/stpipeline
COPY LICENSE /usr/src/stpipeline
COPY README.md /usr/src/stpipeline
COPY AUTHORS.md /usr/src/stpipeline
COPY CHANGELOG.md /usr/src/stpipeline
COPY docs /usr/src/stpipeline/docs
COPY pyproject.toml /usr/src/stpipeline
COPY src /usr/src/stpipeline/src
COPY tests /usr/src/stpipeline/tests

RUN pip install --quiet --upgrade pip && \
    pip install --no-cache-dir --verbose /usr/src/stpipeline && \
    rm -rf "/usr/src/stpipeline" && \
    find /usr/local/lib/python3.11 \( -iname '*.c' -o -iname '*.pxd' -o -iname '*.pyd' -o -iname '__pycache__' \) -printf "\"%p\" " | \
    xargs rm -rf {}

WORKDIR /app

CMD ["st_pipeline_run", "-h"]