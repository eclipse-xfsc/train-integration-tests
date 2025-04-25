from behave import when

from eu.xfsc.bdd.core.steps import rest
from eu.xfsc.bdd.core.models.issuer import Issuer
from eu.xfsc.bdd.core.models.trust_framework_pointer import TrustFrameworkPointer

from eu.xfsc.bdd.train.components.tcr.client import Client
from eu.xfsc.bdd.train.models.endpoint_types import EndpointTypes


class ContextType(rest.ContextType):
    #: Local Interface
    server: Client

    #: Input
    trust_framework_pointers: set[TrustFrameworkPointer]
    issuer: Issuer
    endpoint_types: EndpointTypes


@when("resolve with server")
def run_resolver(context: ContextType) -> None:
    context.requests_response = context.server.resolve(
        trust_framework_pointers=context.trust_framework_pointers,
        issuer=context.issuer,
        endpoint_types=context.endpoint_types,
    )
