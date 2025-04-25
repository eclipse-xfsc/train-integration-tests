import json

from behave import given, when

from eu.xfsc.bdd.core.steps import rest
from eu.xfsc.bdd.core.models.decentralized_identifiers import Did
from eu.xfsc.bdd.core.models.trust_framework_pointer import TrustFrameworkPointer
from eu.xfsc.bdd.core.server.keycloak import KeycloakServer
from eu.xfsc.bdd.core.utils.asserts import replace_alias_placeholder

from eu.xfsc.bdd.train.components.tspa.server import Server
from eu.xfsc.bdd.train.components.tspa.ui import Ui


class ContextType(rest.ContextType):
    tspa_server: Server
    tspa_ui: Ui
    keycloak: KeycloakServer


@given("TSPA Server is up")
def check_tspa_server_up(context: ContextType) -> None:
    context.tspa_server = Server(keycloak=context.keycloak)
    assert context.tspa_server.is_up(), 'is not up'


@given("TSPA UI is up")
def check_tspa_ui_up(context: ContextType) -> None:
    context.tspa_ui = Ui()
    assert context.tspa_ui.is_up(), 'is not up'


@when("TSPA create pointer {pointer:TrustFrameworkPointerAlias}")
def tspa_creating_pointers(context: ContextType,
                           pointer: TrustFrameworkPointer) -> None:

    context.requests_response = context.tspa_server.create_pointer(
        pointer=context.aliases[pointer]
    )


@when("requests DID {did} pointer {pointer} creation in TSPA Server")
def create_did_for_pointer(context: ContextType, did: Did, pointer: TrustFrameworkPointer) -> None:
    context.requests_response = context.tspa_server.create_did_for_pointer(
        did=did,
        pointer=context.aliases[pointer]
    )


@when("remove from TSPA Server DIDs pointer {pointer}")
def remove_did_pointer_from_tspa_server(context: ContextType, pointer: str) -> None:
    context.requests_response = context.tspa_server.remove_did_from_pointer(
        pointer=context.aliases[pointer]
    )


@when("remove from TSPA Server pointer {pointer}")
def remove_pointer_from_tspa_server(context: ContextType, pointer: str) -> None:
    context.requests_response = context.tspa_server.remove_pointer(
        pointer=context.aliases[pointer]
    )


@when("create Trust List with XML payload for pointer {pointer} with content")
def create_trust_list_as_xml_with_content(context: ContextType, pointer: str) -> None:
    context.requests_response = context.tspa_server.create_trust_list_as_xml(
        pointer=context.aliases[pointer],
        xml_data=context.text
    )


@when("create Trust List with XML payload for pointer {pointer} with {alias_key}")
def create_trust_list_as_xml_with_alias(context: ContextType, pointer: str, alias_key: str) -> None:
    context.requests_response = context.tspa_server.create_trust_list_as_xml(
        pointer=context.aliases[pointer],
        xml_data=context.aliases[alias_key]
    )


@when("create Trust List with JSON payload for pointer {pointer} with content")
def create_trust_list_as_json_with_content(context: ContextType, pointer: str) -> None:
    _data = json.loads(context.text)
    replaced = replace_alias_placeholder(_data, context.aliases)
    context.requests_response = context.tspa_server.create_trust_list_as_json(
        pointer=context.aliases[pointer],
        json_data=replaced
    )


@when("create Trust List with JSON payload for pointer {pointer} with {alias_key}")
def create_trust_list_as_json_with_alias(context: ContextType, pointer: str, alias_key: str) -> None:
    context.requests_response = context.tspa_server.create_trust_list_as_json(
        pointer=context.aliases[pointer],
        json_data=context.aliases[alias_key]
    )


@when("read Trust List {pointer}")
def read_trust_list(context: ContextType, pointer: str) -> None:
    context.requests_response = context.tspa_server.read_trust_list(
        pointer=context.aliases[pointer]
    )


@when("read VC {pointer}")
def read_vc(context: ContextType, pointer: str) -> None:
    context.requests_response = context.tspa_server.read_vc(
        pointer=context.aliases[pointer]
    )


@when("remove Trust List {pointer}")
def remove_trust_list(context: ContextType, pointer: str) -> None:
    context.requests_response = context.tspa_server.remove_trust_list(
        pointer=context.aliases[pointer]
    )


@when("publish TSP pointer {pointer} with {alias_key}")
def publish_tsp(context: ContextType, pointer: str, alias_key: str) -> None:
    context.requests_response = context.tspa_server.publish_tsp(
        pointer=context.aliases[pointer],
        json_data=context.aliases[alias_key]
    )


@when("update TSP pointer/tsp_id {pointer}/{tsp_id} with {alias_key}")
def update_tsp(context: ContextType, pointer: str, tsp_id: str, alias_key: str) -> None:
    context.requests_response = context.tspa_server.update_tsp(
        pointer=context.aliases[pointer],
        json_data=context.aliases[alias_key],
        tsp_id=tsp_id
    )


@when("delete TSP pointer/tsp_id {pointer}/{tsp_id}")
def delete_tsp(context: ContextType, pointer: str, tsp_id: str) -> None:
    context.requests_response = context.tspa_server.delete_tsp(
        pointer=context.aliases[pointer],
        tsp_id=tsp_id
    )
