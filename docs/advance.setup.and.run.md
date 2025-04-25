# Advance TRAIN BDD setup

This will include a native setup that allows you to get coverage code coverage,
run with the IDE,
debugging and troubleshooting.

## Clone
* Clone with submodules ([dns-zone-manager], [trusted-content-resolver], [tspa] ...)

  ```bash
  git clone --recurse-submodules git@gitlab.eclipse.org:eclipse/xfsc/train/BDD.git bdd-train
  cd bdd-train/submodule/trusted-content-resolver
  git git submodule update --init --recursive
  
  cd ../../..
  git clone git@gitlab.eclipse.org:eclipse/xfsc/dev-ops/testing/bdd-executor.git bdd-core
  ```

## Ensure the OS tools available

* Docker Engine (Docker Desktop, Podman Machine, Rancher, etc.)
* For macOS or Linux, we provide below instructions on how to set up.
* For Windows, we recommend a Dockerized setup (see [Getting Started](../README.md#getting-started)) or
  a remote (ssh) Linux dev server.

## Setup

There are two ways to set up the development machine:

- [Scripted](../deployment/bare_metal/README.md) (recommended)
- "Manual": You will find the required brew or apt packages list in the previously mentioned Scripted scripts.

## Setup environments [env.sample.sh](../env.sample.sh)

 ```bash
 # Duplicate sample file
 cp env.sample.sh env.sh

 # Configure file
 vim env.sh

 # Start your IDE with new environments
 ./env.sh
 ```

## Setup TCR

```bash
$ cd submodule/trusted-content-resolver-helper
$ make assembly
$ make start
...
 Tomcat started on port(s): ${SERVER_PORT:-8087} (http) with context path
```

Check if tcr is up in a new terminal

```bash  
$ curl http://localhost:${SERVER_PORT}/actuator/health
{"status":"UP" ... }
```

## Setup Zone Manager

```bash
$ cd submodule/dns-zone-manager
$ make docker-build-dns-zone-manager-server-dev
$ make docker-run-dns-zone-manager-server-dev
...
```

## Setup TSPA

See https://gitlab.eclipse.org/eclipse/xfsc/train/tspa/-/blob/master/deploy/local/README.md#how-to-build-the-project-locally

## Execute BDD [features](../features)

From the Repository Root directory (BDD),

```bash   
make run_all_bdd_dev
```

## Generate Runtime coverage report

## Report TCR coverage

```bash
cd submodule/trusted-content-resolver-helper
```

```bash
make coverage-report
```

Open Coverage on macOS

```bash
open ./jars/coverage_with_jar/index.html
```

Open Coverage on Linux
```bash
xdg-open ./jars/coverage_with_jar/index.html
```

----------------------------------------------------------------------------------
[dns-zone-manager]: https://gitlab.eclipse.org/eclipse/xfsc/train/dns-zone-manager
[trusted-content-resolver]: https://gitlab.eclipse.org/eclipse/xfsc/train/trusted-content-resolver
[tspa]: https://gitlab.eclipse.org/eclipse/xfsc/train/tspa


