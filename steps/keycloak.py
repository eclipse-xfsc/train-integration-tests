from behave import given, when, then

from eu.xfsc.bdd.core.server.keycloak import KeycloakServer
from eu.xfsc.bdd.core.server.keycloak import Token

from eu.xfsc.bdd.train import env


class ContextType:
    keycloak: KeycloakServer
    FileToken: Token


@when("fetch Keycloak token")
def fetch_keycloak_token(context: ContextType) -> None:
    context.keycloak.last_token = context.keycloak.fetch_token()


@given("ZM Keycloak is up")
def check_zm_keycloak_up(context: ContextType) -> None:
    # FIXME: Rethink concept of the configuration
    # env, config files ... research for a lib like sping boot to read in this order priority: env, config

    context.keycloak = KeycloakServer(
        host=env.ZM_KEYCLOAK_URL,  # type: ignore[arg-type]
        client_secret=env.ZM_KEYCLOAK_CLIENT_SECRET,
        client_id=env.ZM_KEYCLOAK_CLIENT_ID,
        realm=env.ZM_KEYCLOAK_REALM,
        scope=env.ZM_KEYCLOAK_SCOPE
    )
    assert context.keycloak.is_up(), 'is not up'


@given("TSPA Keycloak is up")
def check_tspa_keycloak_up(context: ContextType) -> None:
    context.keycloak = KeycloakServer(
        host=env.TSPA_KEYCLOAK_URL,  # type: ignore[arg-type]
        client_secret=env.TSPA_KEYCLOAK_CLIENT_SECRET,
        client_id=env.TSPA_KEYCLOAK_CLIENT_ID,
        realm=env.TSPA_KEYCLOAK_REALM,
        scope=env.TSPA_KEYCLOAK_SCOPE
    )
    assert context.keycloak.is_up(), 'is not up'


@then("save Keycloak token")
def save(context: ContextType) -> None:
    context.FileToken.dump(context.keycloak.last_token)


@given("saved Keycloak token")
def load(context: ContextType) -> None:
    context.keycloak.last_token = context.FileToken.load()

