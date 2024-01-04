FROM golang:1.20.4-alpine as gcs-builder

USER root

RUN apk add git

ARG GCSFUSE_REPO="https://github.com/GoogleCloudPlatform/gcsfuse.git"

WORKDIR /run
RUN git clone ${GCSFUSE_REPO}
WORKDIR /run/gcsfuse
RUN go install ./tools/build_gcsfuse
RUN build_gcsfuse . /tmp $(git log -1 --format=format:"%H")

FROM dpage/pgadmin4:7.3

USER root

RUN apk add --update --no-cache bash ca-certificates fuse tini

COPY --from=gcs-builder /tmp/bin/gcsfuse /usr/local/bin/gcsfuse
COPY --from=gcs-builder /tmp/sbin/mount.gcsfuse /usr/sbin/mount.gcsfuse


# Set fallback mount directory
ENV MNT_DIR /var/lib/pgadmin

RUN mkdir -p /var/lib/pgadmin
RUN chown 5050:5050 /var/lib/pgadmin

# Copy local code to the container image.
ENV APP_HOME /app
#WORKDIR $APP_HOME
COPY . /app

# Install production dependencies.
#RUN pip install -r /app/requirements.txt

ENV PGADMIN_DEFAULT_EMAIL=admin@example.com
ENV PGADMIN_DEFAULT_PASSWORD=s3cret123
# Ensure the script is executable
RUN chmod +x /app/gcsfuse_run.sh


# Use tini to manage zombie processes and signal forwarding
# https://github.com/krallin/tini
ENTRYPOINT ["/sbin/tini", "--"] 

# Pass the startup script as arguments to Tini
CMD ["/app/gcsfuse_run.sh"]