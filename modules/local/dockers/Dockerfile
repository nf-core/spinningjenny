# biocorecrg/econ:0.02
# Launch using netlogo-headless.sh
FROM biocorecrg/debian-perlbrew-pyenv3-java:buster

MAINTAINER Luca Cozzuto <lucacozzuto@gmail.com>

ARG NETLOGO_VERSION=6.2.1
ENV NETLOGO_HOME /opt/netlogo

# Download and extract NetLogo to /opt/netlogo.
RUN bash -c 'curl -k -L https://ccl.northwestern.edu/netlogo/${NETLOGO_VERSION}/NetLogo-${NETLOGO_VERSION}-64.tgz > netlogo.tgz'
RUN tar -xvzf netlogo.tgz && \ 
    rm netlogo.tgz && \
    mv NetLogo* $NETLOGO_HOME

COPY ./netlogo-headless.sh $NETLOGO_HOME

ENV PATH ${PATH}:${NETLOGO_HOME}

