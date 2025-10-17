# syntax=docker/dockerfile:1
# Root-level Dockerfile to build Agent Zero on Render without custom build-path fields.

# Use the pre-built base image for A0
FROM agent0ai/agent-zero-base:latest

# Default branch (Render won’t pass build args on free plan)
ARG BRANCH=main
ENV BRANCH=${BRANCH}

# Copy the filesystem overlay from the subfolder (this includes /ins and /exe scripts)
COPY docker/run/fs/ /

# pre installation steps
RUN bash /ins/pre_install.sh $BRANCH

# install A0
RUN bash /ins/install_A0.sh $BRANCH

# install additional software
RUN bash /ins/install_additional.sh $BRANCH

# cleanup repo and install A0 without caching, this speeds up builds
ARG CACHE_DATE=none
RUN echo "cache buster $CACHE_DATE" && bash /ins/install_A02.sh $BRANCH

# post installation steps
RUN bash /ins/post_install.sh $BRANCH

# Expose ports
EXPOSE 22 80 9000-9009

# Make entrypoints executable
RUN chmod +x /exe/initialize.sh /exe/run_A0.sh /exe/run_searxng.sh /exe/run_tunnel_api.sh

# initialize runtime and switch to supervisord
CMD ["/exe/initialize.sh", "$BRANCH"]
