# The MIT License
#
#  Copyright (c) 2015-2019, CloudBees, Inc. and other Jenkins contributors
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

FROM openjdk:8-jdk
MAINTAINER Rafael Munoz G. <rafamunozg@gmail.com>

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

RUN curl https://dl.google.com/go/go1.12.6.linux-amd64.tar.gz | tar -C /usr/local -xz && mkdir -p /usr/local/bazelisk
ENV PATH=$PATH:/usr/local/go/bin:/usr/local/bazelisk/bin
RUN GOPATH=/usr/local/bazelisk go get github.com/bazelbuild/bazelisk \ 
  && chown -R root:staff /usr/local/go \
  && chown -R root:staff /usr/local/bazelisk \
  && rm -rf /home/${user}/.cache \
  && echo '#!/bin/bash\nbazelisk' > /usr/bin/bazel \
  && chmod +x /usr/bin/bazel

USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR} 
ENV GCLOUD_PRESENT=true
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR} \
  && curl https://sdk.cloud.google.com | bash 
ENV PATH=$PATH:/home/${user}/google-cloud-sdk/bin/
RUN gcloud components install --quiet kubectl 

VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}

# Taken from docker-jnlp-slave
COPY jenkins-slave /usr/local/bin/jenkins-slave
ENTRYPOINT ["jenkins-slave"]
