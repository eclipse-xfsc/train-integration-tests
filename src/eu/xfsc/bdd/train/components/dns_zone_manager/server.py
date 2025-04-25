"""
Domain Name System Zone Manager Server
"""
import logging

import pydantic
import requests

from eu.xfsc.bdd.core.defaults import CONNECT_TIMEOUT_IN_SECONDS
from eu.xfsc.bdd.core.models.decentralized_identifiers import Did
from eu.xfsc.bdd.core.models.trust_framework_pointer import \
    TrustFrameworkPointer
from eu.xfsc.bdd.core.server.keycloak import BaseServiceKeycloak
from eu.xfsc.bdd.train.env import ZM_HOST

LOG = logging.getLogger(__name__)


class Server(BaseServiceKeycloak):
    """
    Repo: https://gitlab.eclipse.org/eclipse/xfsc/train/dns-zone-manager
    """
    host: pydantic.HttpUrl = pydantic.HttpUrl(ZM_HOST or "http://localhost:16001")

    def is_up(self) -> bool:
        url = f"{self.host}status"
        response = self.http.get(url, timeout=CONNECT_TIMEOUT_IN_SECONDS)

        return response.status_code == 200 and response.json()['status'] == "OK"

    def _pointer_url(self, pointer: str) -> str:
        return f"{self.host}names/{pointer}/schemes"

    def _did_url(self, pointer: str) -> str:
        return f"{self.host}names/{pointer}/trust-list"

    def pointer_exist(self, pointer: str) -> bool:
        """
        return 200 with schemes' empty list
        """
        requests_response = self.read_pointer(pointer)
        assert requests_response.status_code == 200, "expect HTTP: 200"

        schemes = requests_response.json()['schemes']

        assert isinstance(schemes, list), "expect schemes as list in response"

        return bool(schemes)

    def create_pointer(self,
                       pointer: TrustFrameworkPointer,
                       included_pointers: set[TrustFrameworkPointer]) -> requests.Response:
        """
        Create Trust Framework Pointer
        """
        self._update_header()

        data = {
            'schemes': list(included_pointers)
        }

        return self.http.put(
            url=self._pointer_url(pointer),
            json=data,
            timeout=CONNECT_TIMEOUT_IN_SECONDS
        )

    def read_zones(self) -> requests.Response:
        self._update_header()

        return self.http.get(
            f"{self.host}view-zone",
            timeout=CONNECT_TIMEOUT_IN_SECONDS
        )

    def read_pointer(self, alias: str) -> requests.Response:
        self._update_header()

        return self.http.get(
            url=self._pointer_url(alias),
            timeout=CONNECT_TIMEOUT_IN_SECONDS
        )

    def remove_pointer(self, pointer: str) -> requests.Response:
        self._update_header()

        return self.http.delete(
            url=self._pointer_url(pointer),
            timeout=CONNECT_TIMEOUT_IN_SECONDS
        )

    def remove_did_from_pointer(self, pointer: str) -> requests.Response:
        self._update_header()

        return self.http.delete(
            url=self._did_url(pointer),
            timeout=CONNECT_TIMEOUT_IN_SECONDS
        )

    def create_did_for_pointer(self, did: Did, pointer: str) -> requests.Response:
        """
        Bind existing Trust Framework Pointer to a DID
        """
        self._update_header()

        data = {
            'did': did
        }
        return self.http.put(
            url=self._did_url(pointer),
            json=data,
            timeout=CONNECT_TIMEOUT_IN_SECONDS
        )

    def read_did_for_pointer(self, pointer: str) -> requests.Response:
        self._update_header()

        return self.http.get(
            url=self._did_url(pointer),
            timeout=CONNECT_TIMEOUT_IN_SECONDS
        )
