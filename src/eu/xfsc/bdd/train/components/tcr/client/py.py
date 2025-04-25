"""
Trusted content resolver python client wrapper
"""
from functools import cached_property

from eu.xfsc.bdd.core.client import runner
from eu.xfsc.bdd.train import env

from ._base import MinusMinusBaseClient


class Py(MinusMinusBaseClient):
    """
    BDD step implementation for Python Client
    """

    @cached_property
    def runner(self) -> runner.Runner:
        """Runner Factory Method"""

        if env.TCR_CLIENT_CLI_PY_TYPE:

            if env.TCR_CLIENT_CLI_PY_TYPE.lower() == 'script':
                assert env.TCR_CLIENT_CLI_PY_SCRIPT_PATH, \
                    'env TCR_CLIENT_CLI_PY_SCRIPT_PATH is not set'
                return runner.NativeScript(cli_app_location=env.TCR_CLIENT_CLI_PY_SCRIPT_PATH)

            if env.TCR_CLIENT_CLI_PY_TYPE.lower() in ('docker', 'podman'):
                assert env.TCR_CLIENT_CLI_PY_DOCKER_IMAGE, \
                    'env TCR_CLIENT_CLI_PY_DOCKER_IMAGE is not set'
                return runner.Dockerized(
                    implementation=env.TCR_CLIENT_CLI_PY_TYPE,
                    image_name=env.TCR_CLIENT_CLI_PY_DOCKER_IMAGE
                )

        raise NotImplementedError(
            f"Client type {env.TCR_CLIENT_CLI_PY_TYPE=!r} is not implemented in "
            f"{runner.CLI_SCRIPT_RUNNER=!r}")
