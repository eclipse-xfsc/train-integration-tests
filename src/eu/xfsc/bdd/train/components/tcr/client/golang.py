"""
Trusted content resolver go client wrapper
"""
from functools import cached_property

from eu.xfsc.bdd.core.client import runner
from eu.xfsc.bdd.train import env

from ._base import BaseClient


class Golang(BaseClient):
    """
    BDD step implementation for Golang Client
    """

    @cached_property
    def runner(self) -> runner.Runner:
        """Runner Factory Method"""

        if env.TCR_CLIENT_CLI_GO_SCRIPT_PATH:

            return runner.NativeScript(cli_app_location=env.TCR_CLIENT_CLI_GO_SCRIPT_PATH)

        # golang is pretty portable, so no need for dockerized runner yet

        raise NotImplementedError(
            f"Client type {env.TCR_CLIENT_CLI_GO_SCRIPT_PATH=!r} is not implemented")
