# To Compile, Build and Execute into a Dockerized setup, follow the commands:

## Pull or Build base image ``eu-xfsc-bdd-core``

Follow the instructions [Docker eu-xfsc-bdd-core Images].

## Build

Build images for prod ``eu-xfsc-bdd-train`` and dev ``eu-xfsc-bdd-train-dev`` images.

:NOTE: To delimit local and pulled images,
we changed TRAIN_DOCKER_IMAGE_TAG=latest-local [.env](.env),
default will be ``latest```.

```bash
$ cd deployment/docker
$ export TRAIN_DOCKER_IMAGE_TAG=latest-local && docker-compose up \
  --build --remove-orphans \
  eu-xfsc-bdd-train eu-xfsc-bdd-train-dev
$ docker-compose images
CONTAINER               REPOSITORY                                               TAG                 IMAGE ID            SIZE
eu-xfsc-bdd-train       node-654e3bca7fbeeed18f81d7c7.ps-xaas.io/train/bdd       latest-local        d96e0de86436        2.66GB
eu-xfsc-bdd-train-dev   node-654e3bca7fbeeed18f81d7c7.ps-xaas.io/train/bdd-dev   latest-local        cea001178f41        2.84GB
```

## Pull

```bash
$ docker pull node-654e3bca7fbeeed18f81d7c7.ps-xaas.io/train/bdd
$ docker images | grep "train/bdd.*latest "
node-654e3bca7fbeeed18f81d7c7.ps-xaas.io/train/bdd    latest    38a6171bed53    2 months ago    1.18GB
```

----------------------------------------------------------------------------------
[Docker eu-xfsc-bdd-core Images]: https://gitlab.eclipse.org/eclipse/xfsc/dev-ops/testing/bdd-executor/-/blob/main/deployment/docker/README.md

