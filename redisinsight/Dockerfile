FROM redislabs/redisinsight:1.14.0

USER root

# Install system dependencies
RUN set -e; \
    apt-get update -y && apt-get install -y \
    tini \
    lsb-release \
    gnupg2; \
    gcsFuseRepo=gcsfuse-`lsb_release -c -s`; \
    echo "deb http://packages.cloud.google.com/apt $gcsFuseRepo main" | \
    tee /etc/apt/sources.list.d/gcsfuse.list; \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    apt-key add -; \
    apt-get update; \
    apt-get install -y gcsfuse \
    && apt-get clean

# Set fallback mount directory
ENV MNT_DIR /root/.redisinsight-v2

RUN mkdir -p /db
RUN chown redisinsight:redisinsight /db

# Copy local code to the container image.
ENV APP_HOME /app
#WORKDIR $APP_HOME
COPY . /app

# Install production dependencies.
RUN pip install -r /app/requirements.txt

# Ensure the script is executable
RUN chmod +x /app/gcsfuse_run.sh

USER 1001

# Use tini to manage zombie processes and signal forwarding
# https://github.com/krallin/tini
ENTRYPOINT ["/usr/bin/tini", "--"] 

# Pass the startup script as arguments to Tini
CMD ["/app/gcsfuse_run.sh"]