import re
from typing import cast

import bash
from behave import given, when, then

from eu.xfsc.bdd.core.models.decentralized_identifiers import Did
from eu.xfsc.bdd.core.models.issuer import Issuer
from eu.xfsc.bdd.core.steps import rest
from eu.xfsc.bdd.train.components.tcr.client.golang import Golang
from eu.xfsc.bdd.train.components.tcr.client.java import Java
from eu.xfsc.bdd.train.components.tcr.client.py import Py
from eu.xfsc.bdd.train.components.tcr.client.js import Js
from eu.xfsc.bdd.train.components.tcr.client import Client
from eu.xfsc.bdd.train.components.tcr.utils import validate_json_with_pydantic


from eu_xfsc_train_tcr import ValidateResponse  # type: ignore[attr-defined]


class ContextType(rest.ContextType):
    server: Client
    client: Py | Java | Golang | Js

    #: Input
    did: Did
    issuer: Issuer
    endpoints: set[str]

    validate_response: ValidateResponse
    validate_response_str: str


@given("input DID `{did}` provided")
def add_did(context: ContextType, did: Did) -> None:
    context.did = Did(did)


@given("input Endpoints provided")
def add_endpoints(context: ContextType) -> None:
    context.endpoints = set(context.text.format(**context.aliases).splitlines())


@when("validate with the client")
def run_validate_with_client(context: ContextType) -> None:
    command = context.client.tcr_validate(
        did=context.did,
        issuer=context.issuer,
        endpoints=context.endpoints,
    )

    context.validate_response_str = context.client.bash_success(command)


@when("may fail validate with the client")
def run_may_fail_validate_with_client(context: ContextType) -> None:
    command = context.client.tcr_validate(
        did=context.did,
        issuer=context.issuer,
        endpoints=context.endpoints,
    )

    response = bash.bash(command)

    if response.code == 0:
        context.validate_response_str = response.stdout.decode()
        return

    context.validate_response_str = response.stderr.decode()


@then("validation response is valid")
def check_if_validation_response_is_valid(context: ContextType) -> None:
    context.validate_response = cast(
        ValidateResponse,
        validate_json_with_pydantic(context.validate_response_str, ValidateResponse)
    )


@then("validation response content exact match regexp")
def check_validation_response_content_for_exact_match_with_regexp(context: ContextType) -> None:
    pattern = context.text.strip()
    content = context.validate_response_str
    assert re.search(pattern, content), f"{pattern=}\n, request output does not match {content=}"


@when("validate with the server")
def run_validate_with_server(context: ContextType) -> None:
    context.requests_response = context.server.tcr_validate(
        did=context.did,
        issuer=context.issuer,
        endpoints=context.endpoints,
    )


@then("DID is Verified")
def check_did_is_verified(context: ContextType) -> None:
    assert context.validate_response.did_verified is True, \
        f"did_verified is not True:\n {context.validate_response.model_dump_json()}"


@then("DID isn't Verified")
def check_did_is_not_verified(context: ContextType) -> None:
    assert context.validate_response.did_verified is False, \
        f"did_verified is not False:\n {context.validate_response.model_dump_json()}"
