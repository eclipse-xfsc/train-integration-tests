"""
Implementation for TSPA endpoints
"""
# pylint: disable=missing-class-docstring,arguments-differ
from typing import Any

import requests

from ._base_uri_endpoints import UriEndpoint

PREFIX = "tspa-service"
VERSION = "v1"


class TrustListEndpoint(UriEndpoint):
    path: str = f"{PREFIX}/tspa/{VERSION}/{{framework_name}}/trust-list"

    def get(self, framework_name: str) -> requests.Response:
        url = f"{self.host}{self.path.format(framework_name=framework_name)}"
        return self.http.get(
            url=url,
            timeout=self.CONNECT_TIMEOUT_IN_SECONDS
        )

    def delete(self, framework_name: str) -> requests.Response:
        url = f"{self.host}{self.path.format(framework_name=framework_name)}"
        return self.http.delete(
            url=url,
            timeout=self.CONNECT_TIMEOUT_IN_SECONDS
        )


class TrustListTspEndpoint(UriEndpoint):
    path: str = f"{PREFIX}/tspa/{VERSION}/{{framework_name}}/trust-list/tsp"

    def put(self, framework_name: str, json_data: dict[str, Any]) -> requests.Response:
        url = f"{self.host}{self.path.format(framework_name=framework_name)}"
        return self.http.put(
            url=url,
            json=json_data,
            timeout=self.CONNECT_TIMEOUT_IN_SECONDS,
        )


class TrustListTspItemEndpoint(UriEndpoint):
    path: str = f"{PREFIX}/tspa/{VERSION}/{{framework_name}}/trust-list/tsp/{{id}}"

    def delete(self, tsp_id: str, framework_name: str) -> requests.Response:
        url = f"{self.host}{self.path.format(framework_name=framework_name, id=tsp_id)}"
        return self.http.delete(
            url=url,
            timeout=self.CONNECT_TIMEOUT_IN_SECONDS
        )

    def patch(self,
              tsp_id: str,
              framework_name: str,
              json_data: dict[str, Any]) -> requests.Response:
        assert isinstance(json_data, dict)
        url = f"{self.host}{self.path.format(framework_name=framework_name, id=tsp_id)}"
        return self.http.patch(
            url=url,
            json=json_data,
            timeout=self.CONNECT_TIMEOUT_IN_SECONDS
        )


class TrustListXmlEndpoint(UriEndpoint):
    path: str = f"{PREFIX}/tspa/{VERSION}/init/xml/{{framework_name}}/trust-list"

    def put(self, framework_name: str, xml_data: str) -> requests.Response:
        url = f"{self.host}{self.path.format(framework_name=framework_name)}"
        return self.http.put(
            url=url,
            timeout=self.CONNECT_TIMEOUT_IN_SECONDS,
            data=xml_data
        )


class TrustListJsonEndpoint(UriEndpoint):
    path: str = f"{PREFIX}/tspa/{VERSION}/init/json/{{framework_name}}/trust-list"

    def put(self, framework_name: str, json_data: dict[str, Any]) -> requests.Response:
        assert isinstance(json_data, dict)
        url = f"{self.host}{self.path.format(framework_name=framework_name)}"
        return self.http.put(
            url=url,
            timeout=self.CONNECT_TIMEOUT_IN_SECONDS,
            json=json_data
        )


class TrustListVcEndpoint(UriEndpoint):
    path: str = f"{PREFIX}/tspa/{VERSION}/{{framework_name}}/vc/trust-list"

    def get(self, framework_name: str) -> requests.Response:
        url = f"{self.host}{self.path.format(framework_name=framework_name)}"
        return self.http.get(
            url=url,
            timeout=self.CONNECT_TIMEOUT_IN_SECONDS
        )


class _FrameworkNameItemEndpointHandler(UriEndpoint):
    def put(self, framework_name: str, json_data: dict[str, Any]) -> requests.Response:
        url = f"{self.host}{self.path.format(framework_name=framework_name)}"

        return self.http.put(
            url=url,
            json=json_data,
            timeout=self.CONNECT_TIMEOUT_IN_SECONDS,
        )

    def delete(self, framework_name: str) -> requests.Response:
        url = f"{self.host}{self.path.format(framework_name=framework_name)}"
        return self.http.delete(
            url=url,
            timeout=self.CONNECT_TIMEOUT_IN_SECONDS,
        )


class DidEndpoint(_FrameworkNameItemEndpointHandler):
    path: str = f"{PREFIX}/tspa/{VERSION}/{{framework_name}}/did"


class TrustFrameworkEndpoint(_FrameworkNameItemEndpointHandler):
    path: str = f"{PREFIX}/tspa/{VERSION}/trustframework/{{framework_name}}"


class DidConfigurationEndpoint(UriEndpoint):
    path: str = f"{PREFIX}/.well-known/did-configuration.json"

    def get(self) -> requests.Response:
        url = f"{self.host}{self.path}"
        return self.http.get(
            url=url,
            timeout=self.CONNECT_TIMEOUT_IN_SECONDS
        )

    def patch(self,
              tsp_id: str,
              framework_name: str,
              json_data: dict[str, Any]) -> requests.Response:
        url = f"{self.host}{self.path.format(framework_name=framework_name, id=tsp_id)}"
        return self.http.patch(
            url=url,
            json=json_data,
            timeout=self.CONNECT_TIMEOUT_IN_SECONDS,
        )
