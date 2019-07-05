FROM openjdk:8-jdk
MAINTAINER Oleg Nenashev <o.v.nenashev@gmail.com>

ARG VERSION=3.29
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

ENV HOME /home/${user}
RUN groupadd -g ${gid} ${group}
RUN useradd -c "Jenkins user" -d $HOME -u ${uid} -g ${gid} -m ${user}
LABEL Description="This is a base image, which provides the Jenkins agent executable (slave.jar)" Vendor="Jenkins project" Version="${VERSION}"

ARG AGENT_WORKDIR=/home/${user}/agent

RUN echo 'deb http://deb.debian.org/debian stretch-backports main' > /etc/apt/sources.list.d/stretch-backports.list
RUN apt-get update \
   && apt-get install -t stretch-backports git-lfs \
   && apt-get install -y pkg-config zip g++ zlib1g-dev unzip python3
RUN curl --create-dirs -fsSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

RUN curl -o go-installer.tar.gz https://dl.google.com/go/go1.12.6.linux-amd64.tar.gz && tar -C /usr/local -xzf go-installer.tar.gz

USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}

ENV PATH=$PATH:/usr/local/go/bin
RUN go get github.com/bazelbuild/bazelisk
ENV PATH=$PATH:/home/jenkins/go/bin

VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}