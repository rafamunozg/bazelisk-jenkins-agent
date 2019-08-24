# Goals
This docker image implements the latest version of Bazelisk and Go to run Bazel on Jenkins agents. Bazelisk is installed because no bazel plugins were available at the time of its creation.

## Context
The Docker file is based on this one: https://hub.docker.com/r/jenkins/slave/
But Bazelisk needed some additional components in it:
* pkg-config 
* zip 
* g++ 
* zlib1g-dev
* python3

And finally bazelisk

###Starting on version 0.1.5
Additional tools were added to make it easier to integrate with GCP services. The image now includes also:
* gcloud and its common components (bq, gsutil, etc.)
* kubectl

## Usage
The image is meant to be used as it's origin. As a docker container, it'll run in a Kubernetes cluster or as individual image that will talk to the Jenkins master.

### Quick reference to build it
```bash
export IMAGE_VERSION=<x.y.z>
docker build -t rafamunozg/bazelisk-agent:$IMAGE_VERSION .
docker run -it --rm rafamunozg/bazelisk-agent:$IMAGE_VERSION /bin/bash
```

*When ready:*

```bash
docker push rafamunozg/bazelisk-agent:$IMAGE_VERSION
```
