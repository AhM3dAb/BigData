FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i 's|http://archive.ubuntu.com|http://tn.archive.ubuntu.com|g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        sudo \
        openjdk-8-jdk \
        curl \
        gnupg \
        procps \
        wget \
        coreutils \
        libc6-dev \
        vim \
        nano \
        software-properties-common \
        ssh \
        net-tools \
        ca-certificates \
        iputils-ping \
        telnet \
        gettext \
        python3 \
        python3-dev \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Python 3.11
RUN add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        python3.11 \
        python3.11-dev \
        python3.11-distutils \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py \
    && python3.11 /tmp/get-pip.py \
    && rm /tmp/get-pip.py

RUN update-alternatives --install /usr/local/bin/python python /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/local/bin/python3 python3 /usr/bin/python3.11 1

ARG USERNAME=jupyter
ARG GROUPNAME=jupyter
ARG UID=1001
ARG GID=1001

RUN groupadd -g ${GID} ${GROUPNAME} \
    && useradd -m -s /bin/bash -u ${UID} -g ${GID} ${USERNAME} \
    && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

USER ${USERNAME}

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Hadoop
ARG HADOOP_VERSION=3.3.6
ARG HADOOP_URL=https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
ENV HADOOP_HOME=/opt/hadoop

RUN set -eux \
    && curl -fsSL https://downloads.apache.org/hadoop/common/KEYS -o /tmp/hadoop-KEYS \
    && gpg --import /tmp/hadoop-KEYS \
    && sudo mkdir -p ${HADOOP_HOME} \
    && sudo chown ${USERNAME}:${GROUPNAME} ${HADOOP_HOME} \
    && curl -fsSL ${HADOOP_URL} -o /tmp/hadoop.tar.gz \
    && curl -fsSL ${HADOOP_URL}.asc -o /tmp/hadoop.tar.gz.asc \
    && gpg --verify /tmp/hadoop.tar.gz.asc /tmp/hadoop.tar.gz \
    && tar -xf /tmp/hadoop.tar.gz -C ${HADOOP_HOME} --strip-components=1 \
    && mkdir -p ${HADOOP_HOME}/logs \
    && rm -f /tmp/hadoop*

ENV HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
ENV PATH=${HADOOP_HOME}/sbin:${HADOOP_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${HADOOP_HOME}/lib/native:${LD_LIBRARY_PATH}

# Spark
ARG SPARK_VERSION=3.5.0
ARG SPARK_URL=https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz
ENV SPARK_HOME=/opt/spark

RUN set -eux \
    && curl -fsSL https://downloads.apache.org/spark/KEYS -o /tmp/spark-KEYS \
    && gpg --import /tmp/spark-KEYS \
    && sudo mkdir -p ${SPARK_HOME} \
    && sudo chown ${USERNAME}:${GROUPNAME} ${SPARK_HOME} \
    && curl -fsSL ${SPARK_URL} -o /tmp/spark.tgz \
    && curl -fsSL ${SPARK_URL}.asc -o /tmp/spark.tgz.asc \
    && gpg --verify /tmp/spark.tgz.asc /tmp/spark.tgz \
    && tar -xf /tmp/spark.tgz -C ${SPARK_HOME} --strip-components=1 \
    && rm -f /tmp/spark* \
    && curl -fsSL https://jdbc.postgresql.org/download/postgresql-42.3.2.jar \
       -o ${SPARK_HOME}/jars/postgresql-42.3.2.jar

ENV PYTHONHASHSEED=1
ENV PYSPARK_PYTHON=python3
ENV SPARK_CONF_DIR=${SPARK_HOME}/conf
ENV PATH=${SPARK_HOME}/sbin:${SPARK_HOME}/bin:${PATH}

# Hive
ARG HIVE_VERSION=3.1.3
ARG HIVE_URL=https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz
ENV HIVE_HOME=/opt/hive

RUN set -eux \
    && curl -fsSL https://archive.apache.org/dist/hive/KEYS -o /tmp/hive-KEYS \
    && gpg --import /tmp/hive-KEYS \
    && sudo mkdir -p ${HIVE_HOME} \
    && sudo chown ${USERNAME}:${GROUPNAME} ${HIVE_HOME} \
    && curl -fsSL ${HIVE_URL} -o /tmp/hive.tar.gz \
    && curl -fsSL ${HIVE_URL}.asc -o /tmp/hive.tar.gz.asc \
    && gpg --verify /tmp/hive.tar.gz.asc /tmp/hive.tar.gz \
    && tar -xf /tmp/hive.tar.gz -C ${HIVE_HOME} --strip-components=1 \
    && rm -f /tmp/hive*

ENV HIVE_CONF_DIR=${HIVE_HOME}/conf
ENV PATH=${HIVE_HOME}/sbin:${HIVE_HOME}/bin:${PATH}

# Config
COPY --chown=${USERNAME}:${GROUPNAME} conf/core-site.xml ${HADOOP_CONF_DIR}/
COPY --chown=${USERNAME}:${GROUPNAME} conf/hdfs-site.xml ${HADOOP_CONF_DIR}/
COPY --chown=${USERNAME}:${GROUPNAME} conf/yarn-site.xml ${HADOOP_CONF_DIR}/
COPY --chown=${USERNAME}:${GROUPNAME} conf/mapred-site.xml ${HADOOP_CONF_DIR}/
COPY --chown=${USERNAME}:${GROUPNAME} conf/workers ${HADOOP_CONF_DIR}/
COPY --chown=${USERNAME}:${GROUPNAME} conf/spark-defaults.conf ${SPARK_CONF_DIR}/
COPY --chown=${USERNAME}:${GROUPNAME} conf/log4j.properties ${SPARK_CONF_DIR}/
COPY --chown=${USERNAME}:${GROUPNAME} conf/hive-site.xml ${HIVE_CONF_DIR}/

RUN ln -s ${HADOOP_CONF_DIR}/workers ${SPARK_CONF_DIR}/workers \
    && ln -s ${HIVE_CONF_DIR}/hive-site.xml ${SPARK_CONF_DIR}/hive-site.xml

# Entry point
COPY entrypoint.sh /usr/local/sbin/entrypoint.sh
RUN sudo chmod +x /usr/local/sbin/entrypoint.sh

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]


