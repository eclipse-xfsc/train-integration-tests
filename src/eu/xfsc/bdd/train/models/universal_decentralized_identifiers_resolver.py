"""
Universal Decentralized Identifiers Resolver Model
"""
# import pydantic
#
# from .._defaults import HOST_UNI_RESOLVER_WEB as DEFAULT_HOST_UNI_RESOLVER_WEB
# from .._env import HOST_UNI_RESOLVER_WEB
# from ..server import SpringBootActuator


# replaced by train.bdd.server._spring_boot_actuator.SpringBootActuator.did_resolver_is_up
# class UniversalDecentralizedIdentifiersResolver(SpringBootActuator):
#     """
#     Universal Decentralized Identifiers Resolver is a REST api.
#
#     See `https://github.com/decentralized-identity/universal-resolver`_
#     """
#
#     host: pydantic.HttpUrl = pydantic.HttpUrl(
#         HOST_UNI_RESOLVER_WEB or DEFAULT_HOST_UNI_RESOLVER_WEB
#     )
