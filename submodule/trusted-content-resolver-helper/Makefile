# see https://makefiletutorial.com/

SHELL := /bin/bash -eu -o pipefail
PROJ = $(CURDIR)/../trusted-content-resolver
JAVA_JACOCO_VERSION ?= 0.8.9
TCR_SERVER_VERSION ?= 1.1.0-SNAPSHOT

_JMX=-Djava.rmi.server.hostname=0.0.0.0 -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=9999 -Dcom.sun.management.jmxremote.rmi.port=1199 -Dcom.sun.management.jmxremote.local.only=false
_JAVA_AGENT_DEV=-javaagent:$(CURDIR)/jars/org.jacoco.agent-$(JAVA_JACOCO_VERSION)-runtime.jar=jmx=true
_JAVA_AGENT_CONTAINER=-javaagent:/mounted/helpers/jars/org.jacoco.agent-$(JAVA_JACOCO_VERSION)-runtime.jar=jmx=true
TCR_SERVER_IMAGE := node-654e3bca7fbeeed18f81d7c7.ps-xaas.io/train/trusted-content-resolver-service

DOCKER := $${DOCKER_ENGINE:-docker} # or DOCKER_ENGINE=podman make start_as_container

assembly:
	cd $(PROJ) && \
	mvn clean install -Dmaven.test.skip=true

clean_tcr:
	rm -rf $(CURDIR)/{jars,jacoco*.exec,logs}
	rm -rfv $(PROJ)/service/{logs}

./jars/*.jar:
	# based on https://ankeetmaini.dev/posts/getting-e2e-tests-coverage-for-java/
	mkdir -p "./jars/"
	wget \
		--no-clobber \
		-P "./jars/" \
		https://repo1.maven.org/maven2/org/jacoco/org.jacoco.cli/$(JAVA_JACOCO_VERSION)/org.jacoco.cli-$(JAVA_JACOCO_VERSION)-nodeps.jar
	wget \
		--no-clobber\
		-P "./jars/" \
		https://repo1.maven.org/maven2/org/jacoco/org.jacoco.agent/$(JAVA_JACOCO_VERSION)/org.jacoco.agent-$(JAVA_JACOCO_VERSION)-runtime.jar

download_agent: ./jars/*.jar

# important (!) coverage for start_with_mvn is not working, use start_with_jar
start_with_mvn: start-uni-resolver clean_tcr download_agent
	cd $(PROJ)/service && \
    export MAVEN_OPTS="$(_JAVA_AGENT_DEV) $(_JMX)" && \
    mvn spring-boot:run

start_with_jar: clean_tcr download_agent
	cd $(PROJ)/service && \
	export JAVA_TOOL_OPTIONS="$(_JAVA_AGENT_DEV) $(_JMX)" && \
   	java -jar target/trusted-content-resolver-service-$(TCR_SERVER_VERSION).jar

start: start_with_jar

coverage-report: download_agent
	# download/dump jacoco-client.exec file into current directory
	java MBeanClient.java

	# convert jacoco-client.exec into coverage folder and xml file
	java -jar jars/org.jacoco.cli-$(JAVA_JACOCO_VERSION)-nodeps.jar \
		report jacoco-client.exec \
			--classfiles=$(PROJ)/service/target/classes \
			--sourcefiles=$(PROJ)/service/src/main/java \
			--html jars/coverage_with_jar  # jars/coverage_with_jar or coverage_with_mvn \


#
# --entrypoint=sh
start_as_container: clean_tcr download_agent
	$(DOCKER) run  \
		--platform=linux/amd64 \
		-it \
		-v $(CURDIR):/mounted/helpers \
		-e SERVER_PORT=$(SERVER_PORT) \
		-e JAVA_TOOL_OPTIONS="$(_JAVA_AGENT_CONTAINER) $(_JMX)" \
		-e TCR_DID_BASE_URI=$(TCR_DID_BASE_URI) \
		--privileged \
		--network host \
		$(TCR_SERVER_IMAGE)

coverage-report_as_container: download_agent
    # download/dump jacoco-client.exec file into current directory
	$(DOCKER) run \
	  --entrypoint java \
	  --platform=linux/amd64 \
      -v $(CURDIR):/mounted/helpers \
      -w /mounted/helpers \
      --network host \
      $(TCR_SERVER_IMAGE) \
    	MBeanClient.java

	# convert jacoco-client.exec into coverage folder and xml file
	$(DOCKER) run \
    	  --entrypoint java \
    	  --platform=linux/amd64 \
          -v $(CURDIR):/mounted/helpers \
          -v $(PROJ)/service:/mounted/service \
          -w /mounted/helpers \
          $(TCR_SERVER_IMAGE) \
        	-jar jars/org.jacoco.cli-$(JAVA_JACOCO_VERSION)-nodeps.jar \
        	report jacoco-client.exec \
            --classfiles=/app/classes \
            --html jars/coverage_report_as_container \
            --xml jars/coverage_report_as_container.xml \
			--sourcefiles=/mounted/service/src/main/java
