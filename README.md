# TRAIN Behavior-Driven Development (BDD) Framework

Based on the XFSC Python-based BDD lib [eu.xfsc.bdd.core]

# Description

CI Automation (Setup, Run and Reports) is set up with Jenkins.
Here's the pipeline visualization from the [Jenkinsfile](Jenkinsfile) `TRAIN` pipeline:

![Jenkins-pipeline-visualisation-for-bdd.train.png](docs/Jenkins-pipeline-visualisation-for-bdd.train.png)

The components' relationship is drawn in Plant UML syntax below.

``` plantuml
@startuml

actor :Admin:

actor :Notary:
actor :Universal Resolver:
actor :DNS:

actor :User:
actor :Developer:
actor :Jenkins:

package "BDD:repo" as BDD {
    component Features
    component Steps
}

package "TCR:repo" as TCR {
    component "TCR Server" 

    package "TCR:repo/Clients" as Clients {
        component Java     
        component Python
        component GoLang
        component JavaScript
    }
  
    interface API
    interface REST
    Clients -- API
    "TCR Server" -- REST
}

package "Zone Manager:repo" as ZM {
    component "KNOT DNS"
    component "ZM Server"
    component "ZM UI"
}

package "TSPA:repo" as TSPA {
    component "TSPA Server"
    component "TSPA UI"
}

Jenkins      --|> User
Developer    --|> User
User         -->  Features: execute

Steps        -->  (REST): use
Steps        -->  [Features]: implements  
Steps        -->  (API): use

"TCR Server" -->  (Universal Resolver): use
(Universal Resolver) --> "TSPA Server": use
"TCR Server" -->  (DNS): use
Java         -->  (REST) : use
Python       -->  (REST) : use
GoLang       -->  (REST) : use
JavaScript   -->  (REST) : use

"ZM UI" --> "ZM Server"
"ZM Server" --> "KNOT DNS": use
"KNOT DNS"   -->  DNS: imlplement

"TSPA UI" -->  "TSPA Server"
"TSPA Server" -->  "ZM Server"
Notary       -->  TSPA

Admin --> "ZM UI"
Admin --> "TSPA UI"
 
@enduml
```

# Getting started

BDD TRAIN depends on multiple components, all of which are shown above in the PlantUML diagram.
To simplify the 'Get Started' procedure, we provide docker-compose setup (see [compose.yml](deployment/docker/compose.yml)).

## env.sh

Since the Framework is configured through OS environments, you have to prepare your [env.sh](env.sample.sh).

```bash
# Duplicate sample file
cp env.sample.sh env.sh

# Configure file
vim env.sh

./env.sh
```

``env.sh`` will be mounted and used later into the Docker ``eu-xfsc-bdd-train`` container.

## List Images Command

Let's assume that we have pulled or built the TRAIN BDD image, and we have:

```bash
docker-compose images
CONTAINER               REPOSITORY                                               TAG                 IMAGE ID            SIZE
eu-xfsc-bdd-train       node-654e3bca7fbeeed18f81d7c7.ps-xaas.io/train/bdd       latest-local        d96e0de86436        2.66GB
eu-xfsc-bdd-train-dev   node-654e3bca7fbeeed18f81d7c7.ps-xaas.io/train/bdd-dev   latest-local        cea001178f41        2.84GB
```
If not, then [build](deployment/docker/README.md#build) or [pull](deployment/docker/README.md#pull) the image.

## Open a bash session within ``eu-xfsc-bdd-train`` just container.

```bash
docker-compose run --rm eu-xfsc-bdd-train bash
```

## Activate ``env.sh``
In the opened session, activate our prepared ``env.sh``

```bash
cd eu.xfsc.bdd.train/
source env.sh
```

## Behave

Finally !, run the BDD tests in the opened session.
```
behave
```

## Screencast

The demo is recorded as an Asciinema screencast
[![asciicast](https://asciinema.org/a/6YkQ5mi2G4KKzDLoNe8KfzTyU.svg)](https://asciinema.org/a/6YkQ5mi2G4KKzDLoNe8KfzTyU)


## Advanced Setup and Run

A more complex setup is described here in [advance.setup.and.run.md](docs/advance.setup.and.run.md).


## License

Apache License Version 2.0 (see [LICENSE](LICENSE)).

----------------------------------------------------------------------------------------
[eu.xfsc.bdd.core]: https://gitlab.eclipse.org/eclipse/xfsc/dev-ops/testing/bdd-executor
