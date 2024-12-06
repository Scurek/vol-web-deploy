# Use Ubuntu 24.04 LTS with Miniconda

FROM continuumio/miniconda3:latest AS builder



# Set environment variables

ENV DEBIAN_FRONTEND=noninteractive \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DATABASE_URL=file:/app/db.sqlite \
    SETUSER=volweb \
    UID=10001



# Create and setup user with proper home directory
RUN useradd -m -s /bin/bash -u ${UID} ${SETUSER} && \
    mkdir -p /home/${SETUSER}/.npm && \
    chown -R ${SETUSER}:${SETUSER} /home/${SETUSER}



# Install system dependencies

RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    git \
    curl \
    wget \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    gfortran \
    liblapack-dev \
    libopenblas-dev \
    libxml2 \
    libglpk-dev \
    libxt-dev \
    libcairo2-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*



# Create app directory with proper permissions

WORKDIR /app

RUN chown ${SETUSER}:${SETUSER} /app && \
    mkdir -p /app/db && \
    chown -R ${SETUSER}:${SETUSER} /app/db



# Copy dependency files first for caching

COPY --chown=${SETUSER}:${SETUSER} vol-web-server-dev/requirements.txt /app/

COPY --chown=${SETUSER}:${SETUSER} vol-web-server-dev/package.json /app/



# Create conda environment and install dependencies

RUN conda create -n volweb python=3.8 -y && \
    . /opt/conda/etc/profile.d/conda.sh && \
    conda activate volweb && \
    pip install --no-cache-dir -r /app/requirements.txt && \
    conda clean -afy && \
    npm install --cache /home/${SETUSER}/.npm && \
    npm cache clean --force



# Copy application files

COPY --chown=${SETUSER}:${SETUSER} ./vol-web-server-dev /app/



# Follow README instructions

RUN chmod +x /app/build_client.sh && \
    . /opt/conda/etc/profile.d/conda.sh && \
    conda activate volweb && \
    npm run prisma:init && \
    /app/build_client.sh


# Set up directories and permissions

RUN chmod -R 770 /app/db /app/modules


# Expose port

EXPOSE 8080