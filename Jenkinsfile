pipeline {
    agent {
        kubernetes {
            defaultContainer "python"
            // language=yaml
            yaml """
---
apiVersion: v1
kind: Pod

spec:
  restartPolicy: Never
   
  hostAliases: # this is a placeholder, to be updated when domain available
  - ip: "10.111.252.111"
    hostnames:
    - "tcr.train1.xfsc.dev" 
    - "tspa.train1.xfsc.dev"
    - "zonemgr.train1.xfsc.dev"
  containers:
    - name: python
      
      # see: 
      # make docker-build-and-push-image-python-with-podman
      # make podman-build-and-push-image-python-with-podman
      image: "node-654e3bca7fbeeed18f81d7c7.ps-xaas.io/train/bdd/python_with_podman:3.11"

      command:
        - cat
      tty: true
      securityContext:
        privileged: true
      volumeMounts:
        - mountPath: /var/lib/containers
          name: podman-volume
        - mountPath: /dev/shm
          name: dev-shm-volume
        - mountPath: /var/run
          name: var-run-volume
        - mountPath: /tmp
          name: tmp-volume
 
  volumes:
    - name: podman-volume
      emptyDir: {}
    - name: dev-shm-volume
      emptyDir:
        medium: Memory
    - name: var-run-volume
      emptyDir: {}
    - name: tmp-volume
      emptyDir: {}

"""
        }
    }
    environment {
        // HARBOR_HOST available as env
        HARBOR_PROJECT = "train"

        // available as env
        // TRAIN_ZM_KEYCLOAK_URL
        // TRAIN_ZM_KEYCLOAK_REALM
        // TRAIN_ZM_KEYCLOAK_CLIENT_ID
        // TRAIN_ZM_KEYCLOAK_CLIENT_SECRET
        // TRAIN_ZM_KEYCLOAK_SCOPE
        //
        // TRAIN_TSPA_KEYCLOAK_URL
        // TRAIN_TSPA_KEYCLOAK_REALM
        // TRAIN_TSPA_KEYCLOAK_CLIENT_ID
        // TRAIN_TSPA_KEYCLOAK_CLIENT_SECRET
        // TRAIN_TSPA_KEYCLOAK_SCOPE

        EU_XFSC_BDD_CORE_BRANCH = "main"
        EU_XFSC_BDD_CORE_PATH = "${WORKSPACE}/eclipse/xfsc/dev-ops/testing/bdd-executor"

        VENV_PATH_DEV = "${WORKSPACE}/.cache/.venv"
        PYLINTHOME = "${WORKSPACE}/.cache/pylint"
        PIP_CACHE_DIR = "${WORKSPACE}/.cache/pip"

        TRAIN_TCR_HOST = "http://tcr-service.trust-content-res.svc.cluster.local:8087"
        TRAIN_DNS_ZM_SERVER_HOST = "http://nsd-service-rest.dns-zm.svc.cluster.local:16001"
        TRAIN_TSPA_SERVER_HOST = "http://tspa-service.tspa.svc.cluster.local:8080"

        TRAIN_ENV = "jenkins-train"
        ARG_BDD_JUNIT = "--junit --junit-directory=.tmp/behave/"

        // clients

        TRAIN_TCR_CLIENT_PY_TYPE = "script"
        TRAIN_TCR_CLIENT_PY_SCRIPT_PATH = "/root/.python.d/dev/eclipse/xfsc/dev-ops/testing/bdd-executor/train/bin/eu-xfsc-train-tcr"

        TRAIN_TCR_CLIENT_JAVA_TYPE = "jar"
        TRAIN_TCR_CLIENT_JAVA_JAR_PATH = "${WORKSPACE}/submodule/trusted-content-resolver/clients/java/target/trusted-content-resolver-java-client-*-full.jar"

        TRAIN_TCR_CLIENT_GO_SCRIPT_PATH = "${WORKSPACE}/submodule/trusted-content-resolver/clients/go/bin/trusted-content-resolver-go-client.bin"

        TRAIN_TCR_CLIENT_JS_TYPE = "script"
        TRAIN_TCR_CLIENT_JS_SCRIPT_PATH = "${WORKSPACE}/submodule/trusted-content-resolver/clients/js/src/cmd/cli.js"
    }

    stages {
        stage('Clone sources') {
            steps {
                // language=sh
                sh '''#!/bin/bash
                set -x -eu -o pipefail
                
                mkdir -p "${EU_XFSC_BDD_CORE_PATH}/.."
                cd "${EU_XFSC_BDD_CORE_PATH}/.."

                git clone https://gitlab.eclipse.org/eclipse/xfsc/dev-ops/testing/bdd-executor.git \
                  -b ${EU_XFSC_BDD_CORE_BRANCH}
                '''
            }
        }

        stage("Build - Jenkins Python+Podman Image") {
            when {
                changeset "deployment/Jenkins/podman/Dockerfile"
            }

            steps {
                withCredentials([
                        string(credentialsId: 'HARBOR_PASSWORD', variable: 'HARBOR_PASSWORD'),
                        string(credentialsId: 'HARBOR_USERNAME', variable: 'HARBOR_USERNAME'),
                ]) {
                    // language=sh
                    sh '''/usr/bin/bash

                    make podman-build-and-push-image-python-with-podman
                    '''
                }
            }
        }

//        stage("Check - Ubuntu Ansible Automation") {
//            when {
//                anyOf {
//                    changeset "Makefile"
//                    changeset 'deployment/bare_metal/main.ansible.yaml'
//                    changeset 'deployment/bare_metal/python.ansible.yaml'
//                }
//            }
//
//            steps {
//                // language=sh
//                sh '''/usr/bin/bash
//                bash -x deployment/bare_metal/ubuntu.23.10.sh
//                deployment/Jenkins/scripts/make_coverage.py
//                '''
//            }
//        }

        stage("Prepare cache folders") {
            steps {
                // language=sh
                sh '''#!/bin/bash
                set -x -eu -o pipefail

                mkdir -p "${PYLINTHOME}/"
                mkdir -p "${PIP_CACHE_DIR}/"
                '''
            }
        }

        stage("TMP:Install - Java") {
            when {
                not {
                    changeset "deployment/Jenkins/podman/Dockerfile"
                }
            }
            steps {
                // language=sh
                sh '''#!/bin/bash
                set -x -eu -o pipefail

                apt install -y wget apt-transport-https gpg
                wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null
                echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
                apt update # update if you haven't already
                apt install temurin-21-jdk -y
                apt install maven -y
                java --version
                '''
            }
        }

        stage("TMP:Generate Clients") {
            when {
                not {
                    changeset "deployment/Jenkins/podman/Dockerfile"
                }
            }
            steps {
                // language=sh
                sh '''#!/bin/bash

                set -eu -o pipefail

                cd submodule
                git clone --recurse-submodules https://gitlab.eclipse.org/eclipse/xfsc/train/trusted-content-resolver.git

                cd trusted-content-resolver-helper
                make assembly
                '''
            }
        }

        stage("Build - Python") {
            when {
                not {
                    changeset "deployment/Jenkins/podman/Dockerfile"
                }
            }
            steps {
                // language=sh
                sh '''#!/bin/bash
                set -x -eu -o pipefail
                
                make setup_dev
                '''
            }
        }

        stage("Test") {
            when {
                not {
                    changeset "deployment/Jenkins/podman/Dockerfile"
                }
            }
            parallel {
                stage("isort") {
                    steps {
                        // language=sh
                        sh '''#!/bin/bash
                        set -x -eu -o pipefail
                        
                        make isort
                        '''
                    }
                }
                stage("pylint") {
                    steps {
                        // language=sh
                        sh '''#!/bin/bash
                        set -x -eu -o pipefail
                        
                        export ARG_PYLINT_JUNIT=--output-format=junit
                        make pylint > ".tmp/pylint.xml" 
                        '''
                    }
                    post {
                        always {
                            recordIssues \
                                enabledForFailure: true,
                                aggregatingResults: true,
                                tool: pyLint(pattern: ".tmp/pylint.xml")
                        }
                    }
                }
                stage("coverage") {
                    steps {
                        // language=sh
                        sh '''#!/bin/bash
                        set -x -eu -o pipefail
                        
                        export ARG_COVERAGE_PYTEST=--junit-xml=".tmp/pytest.xml"
                        make coverage_run coverage_report
                        '''
                    }
                    post {
                        always {
                            junit ".tmp/pytest.xml"
                        }
                    }
                }
                stage("mypy") {
                    steps {
                        // language=sh
                        sh '''#!/bin/bash
                        set -x -eu -o pipefail
                        
                        export ARG_MYPY_SOURCE_XML=--junit-xml=".tmp/mypy-source.xml"
                        export ARG_MYPY_STEPS_XML=--junit-xml=".tmp/mypy-steps.xml"
                        make mypy
                        '''
                    }
                    post {
                        always {
                            recordIssues enabledForFailure: true, tools: [myPy(pattern: ".tmp/mypy*.xml")]
                        }
                    }
                }
                stage("licensecheck") {
                    steps {
                        // language=sh
                        sh '''/usr/bin/bash

                        make licensecheck
                        # TODO: open a tread in MR to resolve drifted license or version in case needed
                        '''
                    }
                }

                stage("behave") {
                    stages {
                        stage("Submodules") {
                            stages {
                                stage("Run behave") {
                                    stages {
                                        stage("TMP:Install - NodeJs") {
                                            steps {
                                                // language=sh
                                                sh '''#!/bin/bash
                                                set -x -eu -o pipefail

                                                apt install nodejs npm -y
                                                node --version
                                                npm --version
                                                '''
                                            }
                                        }
                                        stage("Install - TCR JS client") {
                                            steps {
                                                // language=sh
                                                sh '''#!/bin/bash
                                                set -x -eu -o pipefail

                                                cd submodule/trusted-content-resolver/clients/js/src/generated/
                                                # do to some unsolved bug the code generation is little broken
                                                # it is fixed with some small text replace
                                                sed --in-place=.bkp 's|babel src -d dist|babel tcr -d dist|g' ./package.json
                                                sed --in-place=.bkp 's|tcr-address|\\x27tcr-address\\x27|g' ./tcr/ApiClient.js

                                                npm install
                                                cd ../cmd
                                                npm install

                                                ./cli.js --help
                                                '''
                                            }
                                        }
                                        stage("BDD Zone Manager") {
                                            steps {
                                                // language=sh
                                                sh '''#!/bin/bash
                                                set -x -eu -o pipefail
                                                
                                                # see ARG_BDD_JUNIT
                                                make run_zm_bdd_dev
                                                '''
                                            }
                                        }
                                        stage("BDD Trust Framework") {
                                            steps {
                                                // language=sh
                                                sh '''#!/bin/bash
                                                set -x -eu -o pipefail
                                                
                                                # see ARG_BDD_JUNIT
                                                make run_tspa_bdd_dev
                                                '''
                                            }
                                        }
                                        stage("BDD TCR") {
                                            steps {
                                                // language=sh
                                                sh '''#!/bin/bash
                                                set -x -eu -o pipefail
                                                
                                                # see ARG_BDD_JUNIT
                                                make run_tcr_bdd_dev
                                                '''
                                            }
                                            post {
                                                always {
                                                    junit ".tmp/behave/*.xml"
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        stage("Deliver reports") {
            steps {
                // language=sh
                sh '''#!/bin/bash
                echo "doing delivery stuff.."
                '''
            }
        }
    }
}