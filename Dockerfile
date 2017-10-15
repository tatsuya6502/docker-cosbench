# We use the Azul OpenJDK because it is a well tested and supported build.
FROM azul/zulu-openjdk:8

ENV JAVA_HOME=/usr/lib/jvm/zulu-8-amd64
ENV COSBENCH_VERSION 0.4.2.c4
ENV COSBENCH_CHECKSUM abe837ffce3d6f094816103573433f5358c0b27ce56f414a60dceef985750397

RUN (export DEBIAN_FRONTEND=noninteractive && \
     apt-get -qq update && \
     apt-get -qy upgrade && \
     apt-get install --no-install-recommends -qy openssh-client curl ca-certificates vim \
                                                 unzip htop netcat-traditional dc less \
                                                 libnss3 procps && \
     apt-get clean && \
     rm -rf /var/lib/apt/lists/* \
            /tmp/* \
            /var/tmp/*)

RUN (curl --retry 6 -Ls \
         "https://github.com/intel-cloud/cosbench/releases/download/v${COSBENCH_VERSION}/${COSBENCH_VERSION}.zip" \
         > /tmp/cosbench.zip && \
     echo "${COSBENCH_CHECKSUM}  /tmp/cosbench.zip" | sha256sum -c && \
     unzip -q /tmp/cosbench.zip -d /opt/ && \
     mv "/opt/${COSBENCH_VERSION}" /opt/cosbench && \
     rm /tmp/cosbench.zip)

# Fix COSBench scripts for Ubuntu and Debian
RUN (find /opt/cosbench -maxdepth 1 -type f -name \*.sh -exec chmod +x '{}' \; && \
     find /opt/cosbench -maxdepth 1 -type f -name \*.sh -exec sed -i -E 's#^(ba)*sh #/bin/bash #g' '{}' \; && \
     sed -i -E 's#^TOOL_PARAMS="".*#TOOL_PARAMS="-q 1"#g' /opt/cosbench/cosbench-start.sh)

COPY run-cosbench.sh /opt/cosbench/run-cosbench.sh
RUN chmod +x /opt/cosbench/run-cosbench.sh

# COSBench driver port
EXPOSE 18088

# COSBench controller port
EXPOSE 19088

WORKDIR /opt/cosbench

CMD ["/opt/cosbench/run-cosbench.sh"]
