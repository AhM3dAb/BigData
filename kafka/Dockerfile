FROM ubuntu:latest

RUN sed -i -e "s|http://archive.ubuntu.com|http://tn.archive.ubuntu.com|g" /etc/apt/sources.list \
     && apt-get -qq update  \
     && DEBIAN_FRONTEND=noninteractive apt-get -qq install --no-install-recommends \
     sudo \
     openjdk-8-jdk \
     curl \
     gnupg \
     procps \
     python3.11-dev \
     wget \
     #python3-pip \
     #python-is-python3 \
     coreutils \
     libc6-dev \
     curl vim wget nano software-properties-common \
     ssh net-tools ca-certificates iputils-ping telnet gettext  \
     && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/local/bin/python python /usr/bin/python3.11 1
RUN update-alternatives --install /usr/local/bin/python3 python3 /usr/bin/python3.11 1

RUN wget https://bootstrap.pypa.io/get-pip.py \
     && python3 get-pip.py

ARG USERNAME=ahmed
ARG GROUPNAME=isimg
ARG UID=1001
ARG GID=1001

RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
     && chmod 0440 /etc/sudoers.d/$USERNAME \
     && groupadd -g $GID $GROUPNAME \
     && useradd -m -s /bin/bash -u $UID -g $GID $USERNAME

USER $USERNAME

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

# Kafka
ARG KAFKA_VERSION=3.6.1
ARG KAFKA_URL=https://dlcdn.apache.org/kafka/$KAFKA_VERSION/kafka_2.13-$KAFKA_VERSION.tgz
ENV KAFKA_HOME=/opt/kafka
RUN set -x \
     && curl -fsSL https://dlcdn.apache.org/kafka/KEYS -o /tmp/kafka-KEYS  \
     && gpg --import /tmp/kafka-KEYS \
     && sudo mkdir $KAFKA_HOME \
     && sudo chown $USERNAME:$GROUPNAME -R $KAFKA_HOME \
     && curl -fsSL $KAFKA_URL -o /tmp/kafka.tgz \
     && curl -fsSL $KAFKA_URL.asc -o /tmp/kafka.tgz.asc \
     && gpg --verify /tmp/kafka.tgz.asc \
     && tar -xf /tmp/kafka.tgz -C $KAFKA_HOME --strip-components 1 \
     && rm /tmp/kafka*

RUN sudo mkdir $KAFKA_HOME/custom
ENV KAFKA_CONF_DIR=$KAFKA_HOME/custom
ENV PATH=$KAFKA_HOME/sbin:$KAFKA_HOME/bin:$PATH

COPY --chown=$USERNAME:$GROUPNAME scripts/create_cluster_id.sh $KAFKA_CONF_DIR/
COPY --chown=$USERNAME:$GROUPNAME scripts/run.sh $KAFKA_CONF_DIR/
COPY --chown=$USERNAME:$GROUPNAME config/server.properties $KAFKA_CONF_DIR/

COPY scripts/run.sh /usr/local/sbin/run.sh
RUN sudo chmod a+x /usr/local/sbin/run.sh
CMD ["run.sh"]