"""
TSPA Server BDD Wrapper
"""
from typing import Any

# pylint: disable=missing-function-docstring
import pydantic
import requests

from eu.xfsc.bdd.core.models.decentralized_identifiers import Did
from eu.xfsc.bdd.core.models.trust_framework_pointer import \
    TrustFrameworkPointer
from eu.xfsc.bdd.core.server import SpringBootActuator
from eu.xfsc.bdd.core.server.keycloak import BaseServiceKeycloak
from eu.xfsc.bdd.train.env import TSPA_HOST

from . import server_endpoints


class Server(BaseServiceKeycloak, SpringBootActuator):
    """
    Is based on SpringBootActuator
    """
    host: pydantic.HttpUrl = pydantic.HttpUrl(TSPA_HOST or "http://localhost:16003")
    started_from_ide: bool = False

    @property
    def health_url(self) -> str:
        if not self.started_from_ide:
            return f"{self.host}tspa-service/actuator/health"

        return f"{self.host}actuator/health"

    def create_pointer(self, pointer: TrustFrameworkPointer) -> requests.Response:
        self._update_header()
        data = {
            'schemes': [pointer]
        }

        return server_endpoints.TrustFrameworkEndpoint(
            http=self.http,
            host=self.host,
        ).put(pointer, data)

    def create_did_for_pointer(self, did: Did, pointer: TrustFrameworkPointer) -> requests.Response:
        self._update_header()
        data = {
            'did': did
        }

        return server_endpoints.DidEndpoint(
            http=self.http,
            host=self.host
        ).put(pointer, data)

    def remove_did_from_pointer(self, pointer: TrustFrameworkPointer) -> requests.Response:
        self._update_header()

        return server_endpoints.DidEndpoint(
            host=self.host,
            http=self.http,
        ).delete(pointer)

    def remove_pointer(self, pointer: TrustFrameworkPointer) -> requests.Response:
        self._update_header()

        return server_endpoints.TrustFrameworkEndpoint(
            http=self.http,
            host=self.host
        ).delete(pointer)

    def create_trust_list_as_xml(self,
                                 pointer: TrustFrameworkPointer,
                                 xml_data: str) -> requests.Response:
        self._update_header(content_type="application/xml")

        return server_endpoints.TrustListXmlEndpoint(
            host=self.host,
            http=self.http,
        ).put(
            framework_name=pointer,
            xml_data=xml_data
        )

    def create_trust_list_as_json(self,
                                  pointer: TrustFrameworkPointer,
                                  json_data: dict[str, Any]) -> requests.Response:
        self._update_header(content_type="application/json")

        return server_endpoints.TrustListJsonEndpoint(
            host=self.host,
            http=self.http
        ).put(
            framework_name=pointer,
            json_data=json_data
        )

    def read_trust_list(self, pointer: TrustFrameworkPointer) -> requests.Response:
        self._update_header()

        return server_endpoints.TrustListEndpoint(
            host=self.host,
            http=self.http,
        ).get(pointer)

    def read_vc(self, pointer: TrustFrameworkPointer) -> requests.Response:
        self._update_header()

        return server_endpoints.TrustListVcEndpoint(
            host=self.host,
            http=self.http,
        ).get(pointer)

    def remove_trust_list(self, pointer: TrustFrameworkPointer) -> requests.Response:
        self._update_header()

        return server_endpoints.TrustListEndpoint(
            host=self.host,
            http=self.http,
        ).delete(pointer)

    def publish_tsp(self,
                    pointer: TrustFrameworkPointer,
                    json_data: dict[str, Any]) -> requests.Response:
        self._update_header(content_type="application/json")

        return server_endpoints.TrustListTspEndpoint(
            host=self.host,
            http=self.http,
        ).put(
            framework_name=pointer,
            json_data=json_data
        )

    def update_tsp(self, pointer: TrustFrameworkPointer,
                   tsp_id: str,
                   json_data: dict[str, Any]) -> requests.Response:
        self._update_header()

        return server_endpoints.TrustListTspItemEndpoint(
            host=self.host,
            http=self.http,
        ).patch(
            tsp_id=tsp_id,
            framework_name=pointer,
            json_data=json_data
        )

    def delete_tsp(self,
                   pointer: TrustFrameworkPointer,
                   tsp_id: str) -> requests.Response:
        self._update_header()

        return server_endpoints.TrustListTspItemEndpoint(
            host=self.host,
            http=self.http,
        ).delete(
            tsp_id=tsp_id,
            framework_name=pointer
        )
