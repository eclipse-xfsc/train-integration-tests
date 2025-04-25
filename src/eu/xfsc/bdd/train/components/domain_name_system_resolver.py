"""
Domain Name System Resolver Model
"""
# from unittest import mock

# import dns.resolver
# import pydantic

# from train.models.trust_framework_pointer import TrustFrameworkPointer

DNS_TYPE_TO_IP: dict[str, str] = {
    'Default DNS': "x.x.x.1",
    'KNOT#1': "x.x.x.2",
    'NSD#1': "x.x.x.3",
}

# replaced with train.bdd.server._spring_boot_actuator.SpringBootActuator.health.json()
# ['components']['dns-resolver']['details']['resolverIPs']

# class DomainNameSystemResolver(pydantic.BaseModel):
#     """
#     Pre-configurable DNS servers wrapper for:
#     - KNOT
#     - NSD
#     """
#
#     implementation: str
#     ip: str
#     TEST_QNAME: str = "_scheme._trust.did-web.test.train.trust-scheme.de"
#     resolver: dns.resolver.Resolver
#
#     model_config = pydantic.ConfigDict(arbitrary_types_allowed=True)
#
#     @classmethod
#     def init(cls, implementation: str, ip: str) -> "DomainNameSystemResolver":
#         """
#         Factory method which properly initiate API for the lib `dns.resolver`
#
#         :param implementation: DNS implementation name
#         :param ip: internet protocol e.g. 127.0.0.1
#         """
#         if "Mocked " in implementation:
#             mocked = mock.Mock(implementation=implementation, ip=ip)
#             mocked.is_up.return_value = True
#
#             if implementation == "Configured Mocked DNS":
#                 mocked.configured_resolve_trust_framework_pointer.return_value = True
#                 return mocked
#
#             if implementation == "Misconfigured Mocked DNS":
#                 mocked.configured_resolve_trust_framework_pointer.return_value = False
#                 return mocked
#
#             raise NotImplementedError(implementation)
#
#         resolver = dns.resolver.Resolver()
#         resolver.nameservers = [
#             ip
#         ]
#         return cls(
#             implementation=implementation,
#             ip=implementation,
#             resolver=resolver,
#         )
#
#     def _resolve(self, host: str, resource_records: str) -> object:
#         """
#         Query nameservers to find if it can answer to the simplest question.
#         """
#         data = []
#
#         response = self.resolver.resolve(host, resource_records)
#
#         for rdata in response:
#             data.append(rdata)
#
#         return data
#
#     def is_up(self) -> bool:
#         """
#         dns.resolver.LifetimeTimeout if the DNS server is no accessible
#         """
#         try:
#             self._resolve(
#                 self.TEST_QNAME,
#                 "CNAME"
#             )
#         except dns.resolver.NoNameservers as exc:
#             print(exc)
#             return False
#         except dns.resolver.LifetimeTimeout as exc:
#             print(exc)
#             return False
#
#         return True
#
#     def configured_resolve_trust_framework_pointer(self, tfp: TrustFrameworkPointer) -> bool:
#         """Is Trust Framework Pointer configured"""
#         try:
#             self._resolve(
#                 tfp,
#                 "PTR"
#             )
#         except dns.resolver.NoNameservers as exc:
#             print(exc)
#             return False
#         except dns.resolver.LifetimeTimeout as exc:
#             print(exc)
#             return False
#         except dns.rdatatype.UnknownRdatatype as exc:
#             print(exc)
#             return False
#         return True
