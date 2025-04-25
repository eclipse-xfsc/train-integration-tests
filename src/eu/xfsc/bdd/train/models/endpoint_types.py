"""
TODO: to sync with java domain models

    KnownServiceEndpointType:
      type: string
      enum:
        - gx-trust-list-issuer
        - gx-trust-list-schemas
        - gx-trust-list-policies
        - gx-trust-list-apps
        - gx-trust-list-verifier
        - gx-trust-list-authorities
"""
from typing import TypeAlias

EndpointTypes: TypeAlias = set[str]
