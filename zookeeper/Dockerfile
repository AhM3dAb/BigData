FROM ubuntu:latest

ENV zookeeper_worker_1=zookeeper-1
ENV zookeeper_worker_2=zookeeper-2
ENV zookeeper_worker_3=zookeeper-3

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

ARG USERNAME=jupyter
ARG GROUPNAME=jupyter
ARG UID=1001
ARG GID=1001

RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
     && chmod 0440 /etc/sudoers.d/$USERNAME \
     && groupadd -g $GID $GROUPNAME \
     && useradd -m -s /bin/bash -u $UID -g $GID $USERNAME

USER $USERNAME

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

# zookeeper
ARG ZOOKEEPER_VERSION=3.9.1
ARG ZOOKEEPER_URL=https://dlcdn.apache.org/zookeeper/zookeeper-$ZOOKEEPER_VERSION/apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz
ENV ZOOKEEPER_HOME=/opt/zookeeper
RUN set -x \
     && curl -fsSL https://downloads.apache.org/zookeeper/KEYS -o /tmp/zookeeper-KEYS  \
     && gpg --import /tmp/zookeeper-KEYS \
     && sudo mkdir $ZOOKEEPER_HOME \
     && sudo chown $USERNAME:$GROUPNAME -R $ZOOKEEPER_HOME \
     && curl -fsSL $ZOOKEEPER_URL -o /tmp/zookeeper.tar.gz \
     && curl -fsSL $ZOOKEEPER_URL.asc -o /tmp/zookeeper.tar.gz.asc \
     && gpg --verify /tmp/zookeeper.tar.gz.asc \
     && tar -xf /tmp/zookeeper.tar.gz -C $ZOOKEEPER_HOME --strip-components 1 \
     && rm /tmp/zookeeper*

ENV ZOOKEEPER_CONF_DIR=$ZOOKEEPER_HOME/conf
ENV PATH=$ZOOKEEPER_HOME/sbin:$ZOOKEEPER_HOME/bin:$PATH

COPY --chown=$USERNAME:$GROUPNAME conf/zoo.cfg $ZOOKEEPER_CONF_DIR/
COPY --chown=$USERNAME:$GROUPNAME conf/zookeeper_init.sh $ZOOKEEPER_CONF_DIR/
RUN mkdir -p $ZOOKEEPER_HOME/data/
COPY run.sh /usr/local/sbin/run.sh
RUN sudo chmod a+x /usr/local/sbin/run.sh
CMD ["run.sh"]