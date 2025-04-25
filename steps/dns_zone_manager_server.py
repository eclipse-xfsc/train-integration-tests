import requests
from behave import given, when, then

import eu.xfsc.bdd.core.steps.alias
from eu.xfsc.bdd.core.models.decentralized_identifiers import Did
from eu.xfsc.bdd.core.models.trust_framework_pointer import TrustFrameworkPointer
from eu.xfsc.bdd.core.server.keycloak import KeycloakServer, Token

from eu.xfsc.bdd.train.components.dns_zone_manager.server import Server


import _register_types
del _register_types  # just init


Pointers = dict[str, TrustFrameworkPointer]


class ContextType(eu.xfsc.bdd.core.steps.alias.ContextType):
    dns_zone_manager: Server
    keycloak: KeycloakServer
    pointers: Pointers
    requests_response: requests.Response
    FileToken: Token


@given("DNS Zone Manager Server is up")
def check_dns_zm_server_up(context: ContextType) -> None:
    context.dns_zone_manager = Server(keycloak=context.keycloak)
    assert context.dns_zone_manager.is_up(), f"is not up {context.dns_zone_manager.host}"


# noinspection PyBDDParameters
@when("creating pointers: {include_pointers:TrustFrameworkPointerAliases} into {pointer:TrustFrameworkPointerAlias}")
def creating_pointers(context: ContextType,
                      include_pointers: list[TrustFrameworkPointer],
                      pointer: TrustFrameworkPointer) -> None:

    context.requests_response = context.dns_zone_manager.create_pointer(
        pointer=context.aliases[pointer],
        included_pointers=set(context.aliases[pointer] for pointer in include_pointers)
    )


@when("requests from ZM server all the zones")
def requests_zones(context: ContextType) -> None:
    context.requests_response = context.dns_zone_manager.read_zones()


@when("remove from ZM server pointer {pointer}")
def remove_pointer_from_zm_server(context: ContextType, pointer: str) -> None:
    context.requests_response = context.dns_zone_manager.remove_pointer(
        context.aliases[pointer]
    )


@when("remove from ZM server DIDs pointer {pointer}")
def remove_did_pointer_from_zm_server(context: ContextType, pointer: str) -> None:
    context.requests_response = context.dns_zone_manager.remove_did_from_pointer(
        context.aliases[pointer]
    )


@then("delete all zones listed in requests response")
def delete_all_zones_in_listed_in_request_response(context: ContextType) -> None:
    data = context.requests_response.json()
    for item in data['zones']:
        for pointer in item['schemes']:
            value = pointer['name']
            requests_response = context.dns_zone_manager.remove_pointer(value)
            assert requests_response.status_code == 204, (requests_response.status_code, requests_response.text)


@given("all zones deleted in ZM successfully ..")
def remove_all_pointers(context: ContextType) -> None:
    # language=Gherkin
    context.execute_steps("""
        When requests from ZM server all the zones
        Then get http 200:Success code
         And delete all zones listed in requests response
    """)


@when("requests pointer {alias}")
def requests_pointer(context: ContextType, alias: str) -> None:
    context.requests_response = context.dns_zone_manager.read_pointer(context.aliases[alias])


# noinspection PyBDDParameters
@given("Trust Framework Pointers: {pointers:TrustFrameworkPointerAliases}")
def check_pointer_exists(context: ContextType, pointers: list[str]) -> None:
    assert pointers
    for alias in pointers:
        assert alias in context.aliases, f'{alias=} not mapped'
        assert context.dns_zone_manager.pointer_exist(context.aliases[alias])


# noinspection PyBDDParameters
@given("Trust Framework Pointers not exists: {pointers:TrustFrameworkPointerAliases}")
def check_pointer_not_exists(context: ContextType, pointers: list[str]) -> None:
    assert pointers
    for alias in pointers:
        assert alias in context.aliases, f'{alias=} not mapped'
        assert not context.dns_zone_manager.pointer_exist(context.aliases[alias]), f'pointer {alias=} exists'


@when("requests DID {did} pointer {pointer} creation")
def create_did_for_pointer(context: ContextType, did: Did, pointer: TrustFrameworkPointer) -> None:
    context.requests_response = context.dns_zone_manager.create_did_for_pointer(
        did=did,
        pointer=pointer if "." in pointer else context.aliases[pointer]
    )


@when("requests DID for pointer {pointer}")
def read_pointers_did(context: ContextType, pointer: TrustFrameworkPointer) -> None:
    context.requests_response = context.dns_zone_manager.read_did_for_pointer(context.aliases[pointer])
