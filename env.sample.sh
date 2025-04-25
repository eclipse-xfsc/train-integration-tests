#!/usr/bin/env bash
: "Usage

Duplicate sample file
$ cp env.sample.sh env.sh

Configure file
$ vim env.sh

Start your IDE with new environments
$ bash ./env.sh

:Optional: Start from GUI on Desktop
$ ln -s $(pwd)/env.sh ${HOME}/Desktop/init_and_start_train.sh
"

#export TRAIN_ENV="dev-with-docker-compose"  # jenkins-train|local-jenkins|dev-with-docker-compose|dev-use-train|hybrid
export TRAIN_ENV="dev-use-train"  # jenkins-train|local-jenkins|dev-with-docker-compose|dev-use-train|hybrid


case ${TRAIN_ENV} in

  jenkins-train)
    ## this case is just for documentation, to be copy pasted in Jenkinsfile:pipeline.environment
    export TRAIN_TCR_HOST="http://tcr-service.trust-content-res.svc.cluster.local:8087"
    export TRAIN_DNS_ZM_SERVER_HOST="http://nsd-service-rest.dns-zm.svc.cluster.local:16001"
    export TRAIN_TSPA_SERVER_HOST="http://tspa-service.tspa.svc.cluster.local:8080"

    export TRAIN_ZM_KEYCLOAK_URL="https://auth-cloud-wallet.xfsc.dev"
    export TRAIN_ZM_KEYCLOAK_REALM="some-zm-realm"
    export TRAIN_ZM_KEYCLOAK_CLIENT_ID="some-zm-realm-client-id"
    export TRAIN_ZM_KEYCLOAK_CLIENT_SECRET="some-zm-secret-nSSXJodZWiNl11188otw5ijabqPDSl"
    export TRAIN_ZM_KEYCLOAK_SCOPE="openid"

    export TRAIN_TSPA_KEYCLOAK_URL="https://auth-cloud-wallet.xfsc.dev"
    export TRAIN_TSPA_KEYCLOAK_REALM="some-tspa-realm"
    export TRAIN_TSPA_KEYCLOAK_CLIENT_ID="some-tsp-client-id"
    export TRAIN_TSPA_KEYCLOAK_CLIENT_SECRET"some-tsp-secret-nSSXJodZWiNl11188otw5ijabqPDSl"
    export TRAIN_TSPA_KEYCLOAK_SCOPE="openid"
    ;;

  dev-with-docker-compose)
    export TRAIN_DNS_ZM_SERVER_PORT="16001" # 16001

    _TRAIN_KEYCLOAK_URL="http://127.0.0.1:8080"
    _TRAIN_KEYCLOAK_REALM="gxfs-dev-test"
    _TRAIN_KEYCLOAK_CLIENT_ID="xfsctest"
    _TRAIN_KEYCLOAK_CLIENT_SECRET="6GRWUQXZ3p6U0gzVIp0mInAdf1zWuQEJ"
    _TRAIN_KEYCLOAK_SCOPE="openid"

    export TRAIN_ZM_KEYCLOAK_URL="${_TRAIN_KEYCLOAK_URL}"
    export TRAIN_ZM_KEYCLOAK_REALM="${_TRAIN_KEYCLOAK_REALM}"
    export TRAIN_ZM_KEYCLOAK_CLIENT_ID="${_TRAIN_KEYCLOAK_CLIENT_ID}"
    export TRAIN_ZM_KEYCLOAK_CLIENT_SECRET="${_TRAIN_KEYCLOAK_CLIENT_SECRET}"
    export TRAIN_ZM_KEYCLOAK_SCOPE="${_TRAIN_KEYCLOAK_SCOPE}"

    export TRAIN_TSPA_KEYCLOAK_URL="${_TRAIN_KEYCLOAK_URL}"
    export TRAIN_TSPA_KEYCLOAK_REALM="${_TRAIN_KEYCLOAK_REALM}"
    export TRAIN_TSPA_KEYCLOAK_CLIENT_ID="${_TRAIN_KEYCLOAK_CLIENT_ID}"
    export TRAIN_TSPA_KEYCLOAK_CLIENT_SECRET="${_TRAIN_KEYCLOAK_CLIENT_SECRET}"
    export TRAIN_TSPA_KEYCLOAK_SCOPE="${_TRAIN_KEYCLOAK_SCOPE}"

    unset _TRAIN_KEYCLOAK_URL
    unset _TRAIN_KEYCLOAK_REALM
    unset _TRAIN_KEYCLOAK_CLIENT_ID
    unset _TRAIN_KEYCLOAK_CLIENT_SECRET
    unset _TRAIN_KEYCLOAK_SCOPE

    export TRAIN_TSPA_SERVER_PORT="16003" # default: 16003
    export TRAIN_TSPA_SERVER_HOST="http://127.0.0.1:${TRAIN_TSPA_SERVER_PORT}"
    export TRAIN_DNS_ZM_SERVER_HOST="http://127.0.0.1:${TRAIN_DNS_ZM_SERVER_PORT}"

    # :start: TCR configurations
    # use it if TCR is launched local
    export TRAIN_TCR_SERVER_PORT="16005" # default: 8087
    export TRAIN_TCR_HOST="http://127.0.0.1:$TRAIN_TCR_SERVER_PORT" # default: 8087

    export TRAIN_TCR_DNS_HOSTS="" #just to be sure that is default is not changed
    export TRAIN_TCR_DID_BASE_URI="local" # http://localhost:8080/1.0
    # :end: TCR configurations

    # :start: ZM configurations
    # use it if TCR is launched local


    # :end: ZM configurations

    # :start: TSPA configurations
    # use it if TCR is launched local

    # :end: TSPA configurations

    # :start: BDD configurations
    export TRAIN_TCR_CLIENT_PY_TYPE="script"
    export TRAIN_TCR_CLIENT_PY_SCRIPT_PATH="${HOME}/.python.d/dev/eclipse/xfsc/dev-ops/testing/bdd-executor/train/bin/eu-xfsc-train-tcr"
    # export TRAIN_TCR_CLIENT_JAVA_DOCKER_IMAGE="train/java/tcr/trusted-content-resolver-java-client......"

    export TRAIN_TCR_CLIENT_JAVA_TYPE="jar"
    export TRAIN_TCR_CLIENT_JAVA_JAR_PATH="${HOME}/eclipse/xfsc/train/eu.xfsc.bdd.train/submodule/trusted-content-resolver/clients/java/target/trusted-content-resolver-java-client-*-full.jar"
    # export TRAIN_TCR_CLIENT_JAVA_DOCKER_IMAGE="train/java/tcr/client-x.y.z-maven-3.9.5-eclipse-temurin-21......"

    export TRAIN_TCR_CLIENT_GO_SCRIPT_PATH="${HOME}/eclipse/xfsc/train/eu.xfsc.bdd.train/submodule/trusted-content-resolver/clients/go/bin/trusted-content-resolver-go-client.bin"

    export TRAIN_TCR_CLIENT_JS_TYPE="script"
    export TRAIN_TCR_CLIENT_JS_SCRIPT_PATH="${HOME}/eclipse/xfsc/train/eu.xfsc.bdd.train/submodule/trusted-content-resolver/clients/js/src/cmd/cli.js"


    ;;

  dev-use-train)
    export TRAIN_DNS_ZM_SERVER_HOST="https://zonemgr.train1.xfsc.dev"
    export TRAIN_TSPA_SERVER_HOST="https://tspa.train1.xfsc.dev"
    export TRAIN_TCR_HOST="https://tcr.train1.xfsc.dev"

    export TRAIN_ZM_KEYCLOAK_URL="https://auth-cloud-wallet.xfsc.dev"
    export TRAIN_ZM_KEYCLOAK_REALM="some"
    export TRAIN_ZM_KEYCLOAK_CLIENT_ID="some"
    export TRAIN_ZM_KEYCLOAK_CLIENT_SECRET="some"
    export TRAIN_ZM_KEYCLOAK_SCOPE="openid"

    export TRAIN_TSPA_KEYCLOAK_URL="https://auth-cloud-wallet.xfsc.dev"
    export TRAIN_TSPA_KEYCLOAK_REALM="some"
    export TRAIN_TSPA_KEYCLOAK_CLIENT_ID="some"
    export TRAIN_TSPA_KEYCLOAK_CLIENT_SECRET="some-nSSXJodZWi...PDSl"
    export TRAIN_TSPA_KEYCLOAK_SCOPE="openid"


    # :start: BDD configurations
    export TRAIN_TCR_CLIENT_PY_TYPE="script"
    export TRAIN_TCR_CLIENT_PY_SCRIPT_PATH="${HOME}/.python.d/dev/eclipse/xfsc/dev-ops/testing/bdd-executor/train/bin/eu-xfsc-train-tcr"
    # export TRAIN_TCR_CLIENT_JAVA_DOCKER_IMAGE="train/java/tcr/trusted-content-resolver-java-client......"

    export TRAIN_TCR_CLIENT_JAVA_TYPE="jar"
    export TRAIN_TCR_CLIENT_JAVA_JAR_PATH="${HOME}/eclipse/xfsc/train/eu.xfsc.bdd.train/submodule/trusted-content-resolver/clients/java/target/trusted-content-resolver-java-client-*-full.jar"
    # export TRAIN_TCR_CLIENT_JAVA_DOCKER_IMAGE="train/java/tcr/client-x.y.z-maven-3.9.5-eclipse-temurin-21......"

    export TRAIN_TCR_CLIENT_GO_SCRIPT_PATH="${HOME}/eclipse/xfsc/train/eu.xfsc.bdd.train/submodule/trusted-content-resolver/clients/go/bin/trusted-content-resolver-go-client.bin"

    export TRAIN_TCR_CLIENT_JS_TYPE="script"
    export TRAIN_TCR_CLIENT_JS_SCRIPT_PATH="${HOME}/eclipse/xfsc/train/eu.xfsc.bdd.train/submodule/trusted-content-resolver/clients/js/src/cmd/cli.js"
    ;;

  *)
    echo "'${TRAIN_ENV}' Not implemented, yet"
    exit 1
    ;;
esac

# :start: HARBOR configurations
# for CI and manual build/push
export HARBOR_PROJECT="some"
export HARBOR_HOST="some-node-654e3bca7f...81d7c7.ps-xaas.io"
export HARBOR_USERNAME="some"
export HARBOR_PASSWORD="some-2ocAdJQGax...zi"
# :start: end configurations

# start your IDE with new env
# e.g. IntelliJ
/Applications/IntelliJ\ IDEA.app/Contents/MacOS/idea