FROM kameshsampath/kube-dev-tools
LABEL org.opencontainers.image.source https://github.com/kameshsampath/drone-dag-installer
LABEL org.opencontainers.image.authors="Kamesh Sampath<kamesh.sampath@hotmail.com>"

LABEL description="A Drone plugin setup DAG on a k3d cluster"

ENV CONFIGS_PATH=/apps/configs

ADD run.sh /bin/
RUN chmod +x /bin/run.sh \
    && mkdir -p $CONFIGS_PATH

CMD ["/bin/run.sh"]