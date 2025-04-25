from typing import cast

from behave import given, when, then

from eu.xfsc.bdd.core.steps import rest
from eu.xfsc.bdd.core.models.issuer import Issuer
from eu.xfsc.bdd.core.models.trust_framework_pointer import TrustFrameworkPointer

from eu.xfsc.bdd.train.components.tcr.server import TCR
from eu.xfsc.bdd.train.components.tcr.utils import validate_json_with_pydantic
from eu.xfsc.bdd.train.models.resolve_response import ResolveResponseAssert
from eu.xfsc.bdd.train.models.trust_list import TrustList
from eu.xfsc.bdd.train.components.domain_name_system_resolver import DNS_TYPE_TO_IP
from eu.xfsc.bdd.train.components.tcr.client.py import Py
from eu.xfsc.bdd.train.components.tcr.client.java import Java
from eu.xfsc.bdd.train.components.tcr.client.golang import Golang
from eu.xfsc.bdd.train.components.tcr.client.js import Js

from eu.xfsc.bdd.train.models.endpoint_types import EndpointTypes


class ContextType(rest.ContextType):
    #: Local Interface
    client: Py | Java | Golang | Js
    server: TCR

    #: Input
    trust_framework_pointers: set[TrustFrameworkPointer]
    issuer: Issuer
    endpoint_types: EndpointTypes

    #: Output
    trust_list: TrustList
    resolve_response_str: str
    resolve_response: ResolveResponseAssert


@given("that TCR is running")  # type: ignore[misc]
def check_tcr(context: ContextType) -> None:
    context.server = TCR()
    assert context.server.is_up(), "is not up"

    # set defaults
    context.endpoint_types = set()


@given("TCR has DNSSEC enabled")
def check_validate_dns(context: ContextType) -> None:
    assert context.server.dns_sec_enabled


@given("DID Resolver is running")
def check_did_resolver(context: ContextType) -> None:
    assert context.server.did_resolver_is_up


@given("{dns_implementation_type} configured in TCR")
def check_dns_resolver(context: ContextType, dns_implementation_type: str) -> None:
    try:
        ip = DNS_TYPE_TO_IP[dns_implementation_type]
    except KeyError:  # pragma: no cover
        raise NotImplementedError(f"No such DNS implementation type {dns_implementation_type!r}")

    if dns_implementation_type != "Default DNS":
        assert context.server.health.json()['components']['dns-resolver']['details']['resolverIPs'] == [ip]


@given("pointers are `{configured_or_misconfigured}` in DNS")
def check_pointers(context: ContextType, configured_or_misconfigured: str) -> None:
    """
    TODO: check zone manager

    PTR=gxfs.test.train.trust-scheme.de
    ZM_REST_API_URI=https://train.trust-scheme.de
    curl <ZM_REST_API_URI>/<PTR>/schemes -H 'Authorization: Bearer <token>'

    bash-5.2$ PTR=gxfs.test.train.trust-scheme.de
    bash-5.2$
    bash-5.2$ #dig  _scheme._trust.$PTR -t ANY
    bash-5.2$ HOST_FROM_PTR=train.trust-scheme.de
    bash-5.2$ dig $HOST_FROM_PTR _scheme._trust.$PTR -t ANY
    """


@given("{client_name} installed")  # type: ignore[misc]
def add_client(context: ContextType, client_name: str) -> None:
    match client_name:
        case "Java":
            context.client = Java(host=context.server.host)

        case "Python":
            context.client = Py(host=context.server.host)

        case "Golang":
            context.client = Golang(host=context.server.host)

        case "JavaScript":
            context.client = Js(host=context.server.host)

        case _:  # pragma: no cover
            raise NotImplementedError

    assert context.client.is_up()


@given("input pointers provided")
def add_pointers(context: ContextType) -> None:
    _replaced = context.text.format(**context.aliases)
    context.trust_framework_pointers = TrustFrameworkPointer.from_text(_replaced)
    assert context.trust_framework_pointers


@given("input issuer `{issuer}` provided")
def add_issuer(context: ContextType, issuer: Issuer) -> None:
    context.issuer = Issuer(issuer.format(**context.aliases))


@given("input Endpoint Types provided")  # type: ignore[misc]
def add_endpoint_types(context: ContextType) -> None:
    context.endpoint_types = set(context.text.splitlines())


@given("no input Endpoint Types provided")
def add_no_endpoint_types_provided(context: ContextType) -> None:
    context.endpoint_types = set()


@when("resolve with the client")
def run_resolver(context: ContextType) -> None:
    command = context.client.resolve(
            trust_framework_pointers=context.trust_framework_pointers,
            issuer=context.issuer,
            endpoint_types=context.endpoint_types,
        )

    context.resolve_response_str = context.client.bash_success(command)


@then("resolved response is valid")
def check_if_resolved_response_is_valid(context: ContextType) -> None:
    context.resolve_response = cast(
        ResolveResponseAssert,
        validate_json_with_pydantic(context.resolve_response_str, ResolveResponseAssert)
    )


@then("all input pointers are resolved with at least one DID")
def check_all_input_pointers_are_resolved_with_at_least_one_did(context: ContextType) -> None:
    """
    DID Case (1) all pointers resolved with at least one DID (implemented here)
    DID Case (2) all pointers resolved with exact one DID (partially wih (1))
    """
    context.resolve_response.assert_pointers_are_resolved_with_at_least_one_did()


@then("no DID resolved")
def check_no_did_resolver(context: ContextType) -> None:
    """
    DID Case (3) not pointers resolved with DID
    """

    context.resolve_response.assert_no_did_resolve()


@then("all resolved DID has a TL")
def check_all_resolved_did_have_a_tl(context: ContextType) -> None:
    context.resolve_response.assert_resolved_did_do_have_at_least_one_tl()


@then("all resolved DID don't have a TL")
def check_all_resolved_did_does_not_have_a_tl(context: ContextType) -> None:
    context.resolve_response.assert_resolved_did_do_not_have_a_tl()
