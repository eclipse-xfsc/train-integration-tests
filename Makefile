# see https://makefiletutorial.com/

SHELL := /bin/bash -eu -o pipefail

PYTHON_3 ?= python3
PYTHON_D ?= $(HOME)/.python.d
SOURCE_PATHS := "src"
CMD_SELENIUM := train_bdd.selenium # :: NOT Implemented yet

VENV_PATH_DEV := $(PYTHON_D)/dev/eclipse/xfsc/dev-ops/testing/bdd-executor/train
VENV_PATH_PROD := $(PYTHON_D)/prod/eclipse/xfsc/dev-ops/testing/bdd-executor/train

CI_PROJECT_NAME := bdd
PYTHON_WITH_PODMAN_IMAGE := $${HARBOR_HOST}/$${HARBOR_PROJECT}/$(CI_PROJECT_NAME)/python_with_podman:3.11

EU_XFSC_BDD_CORE_PATH ?= ../..
EU_XFSC_BDD_TRAIN_CLIENT_PYTHON_SRC ?= submodule/trusted-content-resolver/clients/py/src

setup_dev: $(VENV_PATH_DEV)
	mkdir -p .tmp/

$(VENV_PATH_DEV):
	$(PYTHON_3) -m venv $(VENV_PATH_DEV)
	"$(VENV_PATH_DEV)/bin/pip" install -U pip wheel
	$(MAKE) install_tcr_client_dev
	cd "$(EU_XFSC_BDD_CORE_PATH)" && "$(VENV_PATH_DEV)/bin/pip" install -e ".[dev]"
	"$(VENV_PATH_DEV)/bin/pip" install -e ".[dev]"
	"$(VENV_PATH_DEV)/bin/pip" freeze > requirements.txt

setup_prod: $(VENV_PATH_PROD)

install_tcr_client_dev:
	cd "$(EU_XFSC_BDD_TRAIN_CLIENT_PYTHON_SRC)/generated" && "$(VENV_PATH_DEV)/bin/pip" install "."
	cd "$(EU_XFSC_BDD_TRAIN_CLIENT_PYTHON_SRC)/cmd" && "$(VENV_PATH_DEV)/bin/pip" install "."

$(VENV_PATH_PROD):
	$(PYTHON_3) -m venv $(VENV_PATH_PROD)
	"$(VENV_PATH_PROD)/bin/pip" install -U pip wheel
	cd "$(EU_XFSC_BDD_TRAIN_CLIENT_PYTHON_SRC)/generated" && "$(VENV_PATH_PROD)/bin/pip" install "."
	cd "$(EU_XFSC_BDD_TRAIN_CLIENT_PYTHON_SRC)/cmd" && "$(VENV_PATH_PROD)/bin/pip" install "."
	cd "$(EU_XFSC_BDD_CORE_PATH)" && "$(VENV_PATH_PROD)/bin/pip" install "."
	"$(VENV_PATH_PROD)/bin/pip" install .

isort: setup_dev
	"$(VENV_PATH_DEV)/bin/isort" $(SOURCE_PATHS) tests

pylint: setup_dev
	"$(VENV_PATH_DEV)/bin/pylint" $${ARG_PYLINT_JUNIT:-} $(SOURCE_PATHS) tests

coverage_run: setup_dev
	"$(VENV_PATH_DEV)/bin/coverage" run -m pytest $${ARG_COVERAGE_PYTEST:-} -m "not integration" tests/ src/

coverage_report: setup_dev
	"$(VENV_PATH_DEV)/bin/coverage" report

mypy: setup_dev
	"$(VENV_PATH_DEV)/bin/mypy" $${ARG_MYPY_SOURCE_XML:-} -p eu.xfsc.bdd.train
	"$(VENV_PATH_DEV)/bin/mypy" $${ARG_MYPY_STEPS_XML:-} steps/ --disable-error-code=misc

code_check: \
	setup_dev \
	isort \
	pylint \
	coverage_run coverage_report \
	mypy

#run_selenium: setup_prod
#	source "$(VENV_PATH_PROD)/bin/activate" && $(CMD_SELENIUM)

run_zm_bdd_dev: setup_dev
	source "$(VENV_PATH_DEV)/bin/activate" && \
		"$(VENV_PATH_DEV)/bin/coverage" run --append -m behave $${ARG_BDD_JUNIT:-} features/01*

run_tspa_bdd_dev: setup_dev
	source "$(VENV_PATH_DEV)/bin/activate" && \
		"$(VENV_PATH_DEV)/bin/coverage" run --append -m behave $${ARG_BDD_JUNIT:-} features/03*

run_tcr_bdd_dev: setup_dev
	source "$(VENV_PATH_DEV)/bin/activate" && \
		"$(VENV_PATH_DEV)/bin/coverage" run --append -m behave $${ARG_BDD_JUNIT:-} features/04* features/05*

run_all_bdd_dev: setup_dev
	source "$(VENV_PATH_DEV)/bin/activate" && \
		"$(VENV_PATH_DEV)/bin/coverage" run --append -m behave $${ARG_BDD_JUNIT:-}

run_all_bdd_dev_html: setup_dev
	mkdir .tmp/behave
	source "$(VENV_PATH_DEV)/bin/activate" && \
		"$(VENV_PATH_DEV)/bin/coverage" run --append -m behave -f html -o ./tmp/behave/behave-report.html

run_all_bdd_prod: setup_prod
	source "$(VENV_PATH_PROD)/bin/activate" && behave features/

run_all_test_coverage: coverage_run run_all_bdd_dev coverage_report

clean_dev:
	rm -rfv "$(VENV_PATH_DEV)"

clean_prod:
	rm -rfv "$(VENV_PATH_PROD)"

activate_env_prod: setup_prod
	@echo "source \"$(VENV_PATH_PROD)/bin/activate\""

activate_env_dev: setup_dev
	@echo "source \"$(VENV_PATH_DEV)/bin/activate\""

ansible:
	cd deployment/bare_metal && ansible-playbook main.ansible.yaml --connection=local -i localhost,

docker-build-and-push-image-python-with-podman: # to be manually if podman is not available on device
	echo -n "$${HARBOR_PASSWORD}" | docker login -u "$${HARBOR_USERNAME}" --password-stdin "$${HARBOR_HOST}"

	docker run --privileged --rm docker.io/tonistiigi/binfmt --install all
	docker buildx create --use

	cd ./deployment/Jenkins/podman/ && \
        docker buildx build -t "$(PYTHON_WITH_PODMAN_IMAGE)" --platform=linux/arm64,linux/amd64 .
	podman logout "$${HARBOR_HOST}"

podman-build-and-push-image-python-with-podman:  # to be invoked by Jenkins
	# see https://medium.com/oracledevs/building-multi-architecture-containers-on-oci-with-podman-67d49a8b965e

	echo -n "$${HARBOR_PASSWORD}" | podman login -u "$${HARBOR_USERNAME}" --password-stdin "$${HARBOR_HOST}"

	platforms=$$(podman run --privileged --rm docker.io/tonistiigi/binfmt --install all | grep -Eo 'linux[^"]+') && \
	cd ./deployment/Jenkins/podman/ && \
		\
		echo '[INFO] starting build...' && \
		manifests=() && \
		for platform in $$platforms; \
		do \
		  	podman build -t $(PYTHON_WITH_PODMAN_IMAGE)-$$(echo $$platform | tr '/' '-') --platform=$$platform . && \
			manifests+=( $(PYTHON_WITH_PODMAN_IMAGE)-$$(echo $$platform | tr '/' '-') ); \
		done && \
		\
        echo '[INFO] starting push...' && \
        for manifest in $${manifests[*]}; \
			do \
				podman push $$manifest;  \
			done && \
		\
        echo '[INFO] Creating Manifests...' && \
			podman manifest create \
            	$(PYTHON_WITH_PODMAN_IMAGE) $${manifests[*]} && \
		\
        echo '[INFO] Pushing manifest...'

	podman manifest push "$(PYTHON_WITH_PODMAN_IMAGE)" "docker://$(PYTHON_WITH_PODMAN_IMAGE)"

	podman manifest rm "$(PYTHON_WITH_PODMAN_IMAGE)"

	podman logout "${HARBOR_HOST}"

licensecheck: setup_dev
	"$(VENV_PATH_DEV)/bin/pip" freeze > ".tmp/requirements.txt"
	cd .tmp/ && "$(VENV_PATH_DEV)/bin/licensecheck" -u requirements > THIRD-PARTY.txt

