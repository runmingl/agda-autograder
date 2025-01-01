ARG BASE_REPO=gradescope/autograder-base
ARG TAG=ubuntu-22.04

FROM ${BASE_REPO}:${TAG}

SHELL ["/bin/bash", "-c"]

# Necessary setup 
RUN apt-get update && \
    apt-get install -y \
    wget \
    curl \
    zlib1g-dev \
    libncurses5-dev \
    nano \
    git \
    build-essential \
    libffi-dev \
    libffi8ubuntu1 \
    libgmp-dev \
    libgmp10 \ 
    libncurses-dev \
    libnuma-dev \
    lsb-release \
    software-properties-common \
    gnupg2 \
    apt-transport-https \
    gcc \
    autoconf \
    automake \
    dos2unix 

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install GHC
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

ENV PATH="/root/.cabal/bin:/root/.ghcup/bin:$PATH"

# Install Agda
RUN cabal update && \
    cabal install Agda

# Install the Agda standard library
RUN wget -O agda-stdlib.tar.gz https://github.com/agda/agda-stdlib/archive/v2.1.1.tar.gz && \
    tar -zxvf agda-stdlib.tar.gz && \
    mv agda-stdlib-2.1.1 /usr/lib/agda-stdlib && \
    rm agda-stdlib.tar.gz

# Install the cubical library
RUN cd /usr/lib && \
    git clone https://github.com/agda/cubical.git

# Set up the Agda environment
RUN mkdir /root/.agda

RUN echo "standard-library" >> /root/.agda/defaults && \
    echo "cubical" >> /root/.agda/defaults

RUN echo "/usr/lib/agda-stdlib/standard-library.agda-lib" >> root/.agda/libraries && \
    echo "/usr/lib/cubical/cubical.agda-lib" >> root/.agda/libraries

# Typecheck the Agda standard library
COPY index.agda /usr/lib/agda-stdlib/src

RUN agda /usr/lib/agda-stdlib/src/index.agda

# Prepare the autograder script
COPY run_autograder /autograder/run_autograder
COPY autograder.py /autograder/autograder.py

RUN dos2unix /autograder/run_autograder
RUN chmod +x /autograder/run_autograder