"""All the client will have the same checks"""
from typing import Optional, cast

import abc
import json
from functools import cached_property

import bash

from eu.xfsc.bdd.core.client import runner
from eu.xfsc.bdd.core.models.decentralized_identifiers import Did
from eu.xfsc.bdd.core.models.issuer import Issuer
from eu.xfsc.bdd.core.models.trust_framework_pointer import \
    TrustFrameworkPointer
from eu.xfsc.bdd.core.server import SpringBootActuator
from eu.xfsc.bdd.train.models.endpoint_types import EndpointTypes

from ._client import Client as TCRClient


class BaseClient(SpringBootActuator, TCRClient, abc.ABC):  # pylint: disable=too-few-public-methods
    """
    Base Class for java, py, go, js, ...
    """
    @cached_property
    @abc.abstractmethod
    def runner(self) -> runner.Runner:
        """Runner Factory Method"""

    @staticmethod
    def bash_success(command: str) -> str:
        """
        Run command with bash interpreter.
        Raise Assertion Error with the error output in case command failed
        """
        response = bash.bash(command)

        output = response.stdout.decode()

        assert response.code == 0, response.stderr.decode()

        return cast(str, output)

    def resolve(self,  # type: ignore[override] # intentional override
                issuer: Issuer,
                trust_framework_pointers: set[TrustFrameworkPointer],
                endpoint_types: Optional[EndpointTypes] = None
                ) -> str:
        """
        Call TCR resolve method
        """
        payload = self._payload(
            issuer=issuer,
            trust_framework_pointers=trust_framework_pointers,
            endpoint_types=endpoint_types
        )

        dump = json.dumps(payload)

        client_arguments = " ".join([
            f"uri='{self.host}{self.VERSION}'",
            "endpoint='resolve'",
            f"data='{dump}'"
        ])

        return self.runner.command(client_arguments)

    # 'validate' method is reserved by pydantic base class
    def tcr_validate(self,  # type: ignore[override]
                     issuer: Issuer,
                     did: Did,
                     endpoints: set[str]) -> str:
        """
        Call the TCR validate method
        """

        dump = json.dumps({
            'issuer': issuer,
            'did': did,
            'endpoints': list(endpoints)
        })

        client_arguments = " ".join([
            f"uri='{self.host}{self.VERSION}'",
            "endpoint='validate'",
            f"data='{dump}'"
        ])

        return self.runner.command(client_arguments)


class MinusMinusBaseClient(BaseClient, abc.ABC):  # pylint: disable=too-few-public-methods
    """
    Use standard CLI with -- and self documentation
    """

    def resolve(self,  # type: ignore[override] # intentional override
                issuer: Issuer,
                trust_framework_pointers: set[TrustFrameworkPointer],
                endpoint_types: Optional[EndpointTypes] = None
                ) -> str:

        client_arguments = " ".join([
            "resolve",
            f"--uri='{self.host}{self.VERSION}'",
            f"--issuer='{issuer}'"
        ] + [
            f"--trust-scheme-pointer='{i}'" for i in trust_framework_pointers
        ] + [
            f"--endpoint-type='{i}'" for i in endpoint_types or []
        ])

        return self.runner.command(client_arguments)

    # 'validate' method is reserved by pydantic base class
    def tcr_validate(self,  # type: ignore[override]
                     issuer: Issuer,
                     did: Did,
                     endpoints: set[str]) -> str:
        """
        Call the TCR validate method
        """

        client_arguments = " ".join([
            "validate",
            f"--uri='{self.host}{self.VERSION}'",
            f"--issuer='{issuer}'",
            f"--did='{did}'"
        ] + [
            f"--endpoint='{i}'" for i in endpoints
        ])

        return self.runner.command(client_arguments)
