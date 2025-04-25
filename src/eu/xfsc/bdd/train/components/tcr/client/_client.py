"""
Python TCR client
"""
from typing import Any, Optional

import pydantic
import requests.exceptions

from eu.xfsc.bdd.core.models.decentralized_identifiers import Did
from eu.xfsc.bdd.core.models.issuer import Issuer
from eu.xfsc.bdd.core.models.trust_framework_pointer import \
    TrustFrameworkPointer
from eu.xfsc.bdd.train.defaults import CONNECT_TIMEOUT_IN_SECONDS
from eu.xfsc.bdd.train.env import TCR_HOST
from eu.xfsc.bdd.train.models.endpoint_types import EndpointTypes


class Client(pydantic.BaseModel):
    """
    Trusted Content Resolver / Extended Universal Resolver (TCR for short) + Libraries

    See `https://gitlab.eclipse.org/eclipse/xfsc/train/trusted-content-resolver/-/blob/main/openapi/tcr_openapi.yaml`_
    """

    host: pydantic.HttpUrl = pydantic.HttpUrl(
        TCR_HOST or "http://localhost:8087"
    )
    VERSION: str = "tcr/v1"

    @staticmethod
    def _payload(issuer: Issuer,
                 trust_framework_pointers: set[TrustFrameworkPointer],
                 endpoint_types: Optional[EndpointTypes] = None) -> dict[str, Any]:
        payload = {
            'issuer': issuer,
            'trustSchemePointers': list(trust_framework_pointers),
        }
        if endpoint_types:
            payload['endpointTypes'] = list(endpoint_types)

        return payload

    def resolve(self,
                issuer: Issuer,
                trust_framework_pointers: set[TrustFrameworkPointer],
                endpoint_types: Optional[EndpointTypes] = None
                ) -> requests.Response:
        """
        Invoke direct `resolve` REST endpoint, no client.
        """
        url = f"{self.host}{self.VERSION}/resolve"
        payload = self._payload(
            issuer=issuer,
            trust_framework_pointers=trust_framework_pointers,
            endpoint_types=endpoint_types
        )
        # print(f"[PRINT:DEBUG] curl -X POST {url} -d '{json.dumps(payload)}' \
        # -H 'Content-Type: application/json'")

        return requests.post(
            url=url,
            json=payload,
            headers={
                'Content-Type': "application/json",
            },
            timeout=CONNECT_TIMEOUT_IN_SECONDS,
        )

    def tcr_validate(self,
                     issuer: Issuer,
                     did: Did,
                     endpoints: set[str]) -> requests.Response:
        """
        Invoke direct `validate` REST endpoint, no client.
        """
        url = f"{self.host}{self.VERSION}/validate"
        payload = {
            'issuer': issuer,
            'did': did,
            'endpoints': list(endpoints)
        }

        return requests.post(
            url=url,
            json=payload,
            headers={
                'Content-Type': "application/json",
            },
            timeout=CONNECT_TIMEOUT_IN_SECONDS,
        )
