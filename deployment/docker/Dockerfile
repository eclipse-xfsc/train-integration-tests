ARG IMAGE_EU_XFSC_BDD_CORE
FROM ${IMAGE_EU_XFSC_BDD_CORE}

USER root

# [1] Install java
RUN apt install wget apt-transport-https gpg -y && \
    wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null && \
    echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list && \
    apt update && \
    apt install temurin-21-jdk -y && \
    apt install maven -y

# [2] Install nodejs
RUN apt install nodejs npm -y

USER xfsc

# [3] Generate and install clients
RUN git clone --recurse-submodules https://gitlab.eclipse.org/eclipse/xfsc/train/trusted-content-resolver.git
# first time it will take some time, needs to download half of internet, install go and build go clients binary.
RUN cd trusted-content-resolver && mvn clean install --define=maven.test.skip=true

# [3.1.1] Install the Python client together with the BDD train
RUN mkdir eu.xfsc.bdd.train
COPY --chown=xfsc setup.cfg setup.py environment.py eu.xfsc.bdd.train/
COPY --chown=xfsc src eu.xfsc.bdd.train/src
COPY --chown=xfsc features eu.xfsc.bdd.train/features
COPY --chown=xfsc steps eu.xfsc.bdd.train/steps
COPY --chown=xfsc steps eu.xfsc.bdd.train/steps


RUN pip install \
    "./trusted-content-resolver/clients/py/src/generated" \
    "./trusted-content-resolver/clients/py/src/cmd" \
    "./eu.xfsc.bdd.train"

# [3.1.2] validate Python
RUN python -c 'import eu.xfsc.bdd.train'
RUN ~/.local/bin/behave --version
RUN ~/.local/bin/eu-xfsc-train-tcr --help

# [3.2] Validate the Java Client
# Unfortunately, it does not have --help method, and we check for an error message
RUN java -jar ./trusted-content-resolver/clients/java/target/trusted-content-resolver-java-client-*-full.jar 2>&1 | grep -q 'no TCR endpoint specified'

# [3.3.1] Install the JS client
# Due to some unsolved bugs, the code generation is a little broken
# It is fixed with some small text replace
RUN cd trusted-content-resolver/clients/js/src/generated/ && \
  sed --in-place=.bkp 's|babel src -d dist|babel tcr -d dist|g' ./package.json && \
  sed --in-place=.bkp 's|tcr-address|\x27tcr-address\x27|g' ./tcr/ApiClient.js && \
  npm install && \
  cd ../cmd && \
  npm install

# [3.3.2] Validate JS client
RUN trusted-content-resolver/clients/js/src/cmd/cli.js --help

# [3.4] Validate Go client
# Unfortunately, it does not have --help method, and we check for an error message
RUN ./trusted-content-resolver/clients/go/bin/trusted-content-resolver-go-client.bin 2>&1 | grep -q 'error: no TCR endpoint specified'
