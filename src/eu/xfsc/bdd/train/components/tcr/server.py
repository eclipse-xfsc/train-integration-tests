"""
Trust Content Resolver Server BDD Wrapper
"""
from typing import cast

from eu.xfsc.bdd.core.server import SpringBootActuator

from . import client


class TCR(client.Client, SpringBootActuator):
    """
    Mixed methods:
    - is_up() check if server is up
    - resolve() send request to server omitting clients
    """

    @property
    def dns_sec_enabled(self) -> bool:
        """Is Domain Name System Security Extensions (DNSSEC) enabled in TCR server ?"""
        return bool(self.health.json()['components']['dns-resolver']['details']['dnsSecEnabled'])

    @property
    def did_resolver_is_up(self) -> bool:
        """Is DID Resolver running ?"""
        return cast(str, self.health.json()['components']['did-resolver']['status']) == "UP"
