"""
Trusted content resolver java client wrapper
"""
from functools import cached_property

from eu.xfsc.bdd.core.client import runner
from eu.xfsc.bdd.train import env

from ._base import BaseClient


class Java(BaseClient):
    """
    BDD step implementation for Java Client
    """

    @cached_property
    def runner(self) -> runner.Runner:
        """Runner Factory Method"""

        if env.TCR_CLIENT_CLI_JAVA_TYPE:

            if env.TCR_CLIENT_CLI_JAVA_TYPE.lower() == 'jar':
                assert env.TCR_CLIENT_CLI_JAVA_JAR_PATH, \
                    'env TCR_CLIENT_CLI_JAVA_JAR_PATH is not set'
                return runner.NativeJava(cli_app_location=env.TCR_CLIENT_CLI_JAVA_JAR_PATH)

            if env.TCR_CLIENT_CLI_JAVA_TYPE.lower() in ('docker', 'podman'):
                assert env.TCR_CLIENT_CLI_JAVA_DOCKER_IMAGE, \
                    'env TCR_CLIENT_CLI_JAVA_DOCKER_IMAGE is not set'
                return runner.Dockerized(
                    implementation=env.TCR_CLIENT_CLI_JAVA_TYPE,
                    image_name=env.TCR_CLIENT_CLI_JAVA_DOCKER_IMAGE
                )

        raise NotImplementedError(
            f"Client type {env.TCR_CLIENT_CLI_JAVA_TYPE=!r} is not implemented in "
            f"{runner.CLI_JAVA_RUNNER=!r}")
