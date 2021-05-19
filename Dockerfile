FROM centos:7

LABEL maintainer="Pengjun Gong <frank.gongpengjun@gmail.com>" \
        description="Memory leaks analyzing image and sample"

# No longer possible to download from OTN with wget/curl
# without authentication and we want Oracle's Java version
# https://www.oracle.com/java/technologies/javase-downloads.html
ADD jdk-8u291-linux-x64.tar.gz /opt/
ENV JAVA_HOME=/opt/jdk1.8.0_291
ENV PATH=${JAVA_HOME}/bin:${PATH}

RUN yum upgrade -y; yum group install -y "Development Tools"; \
    yum install -y wget tcl zlib-devel git docbook-xsl libxslt graphviz python3 tree which; \
    yum clean all

RUN mkdir -p /opt && cd /opt && git clone --depth 1 --branch stable-4 https://github.com/jemalloc/jemalloc.git \
    && mkdir /tmp/jeprof && mkdir /tmp/nmt && mkdir /tmp/pmap \
    && mkdir /diagnostic

RUN cd /opt/jemalloc && ./autogen.sh --enable-prof
RUN cd /opt/jemalloc && make dist
RUN cd /opt/jemalloc && make
RUN cd /opt/jemalloc && make install

ENV LD_PRELOAD="/usr/local/lib/libjemalloc.so"
ENV MALLOC_CONF="prof_leak:true,prof:true,lg_prof_interval:25,lg_prof_sample:18,prof_prefix:/tmp/jeprof"

ENV DIAGNOSTIC_DIR /diagnostic
RUN mkdir -p "$DIAGNOSTIC_DIR"
COPY *.sh $DIAGNOSTIC_DIR/

# git clone --depth 1 git@github.com:gongpengjun/nmt-tools.git
COPY nmt-tools $DIAGNOSTIC_DIR/nmt-tools

ENV SAMPLE_DIR /diagnostic/sample
RUN mkdir -p "$SAMPLE_DIR"
COPY StringInterner.* $SAMPLE_DIR/

WORKDIR $DIAGNOSTIC_DIR
