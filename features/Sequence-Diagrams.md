[04.1 Trusted Content Resolver Server.feature](04.1%20Trusted%20Content%20Resolver%20Server.feature)

``` plantuml
  actor "BDD-Steps"
  participant "TCR-Server"
  actor DID
  actor DNS

  "BDD-Steps" --> "TCR-Server": resolveTrustList(ResolveRequest)
  activate "TCR-Server"
  "TCR-Server" --> DNS: resolveDomain(domain)
  DNS --> "TCR-Server": DID list

  "TCR-Server" --> DID: resolveDid(did, types)
  DID --> "TCR-Server": DIDResolveResult

  "TCR-Server" --> DID: resolveDidConfig(origin)
  DID --> "TCR-Server": DCResolveResult

  "TCR-Server" --> DID: resolveVC(uri)
  DID --> "TCR-Server": VCResolveResult

  "TCR-Server" --> "BDD-Steps": ResolveResponse
  deactivate "TCR-Server"
```

[05 Trusted Content Resolver Validation.feature](05%20Trusted%20Content%20Resolver%20Validation.feature)

Validation Sequence is similar to Resolver beside not querying DNS.

``` plantuml
  actor "BDD-Steps"
  participant "TCR-Server"
  actor DID

  "BDD-Steps" --> "TCR-Server": validateTrustList(validateRequest)
  activate "TCR-Server"
  "TCR-Server" --> DID: resolveDid(did, types)
  DID --> "TCR-Server": DIDResolveResult

  "TCR-Server" --> DID: resolveDidConfig(origin)
  DID --> "TCR-Server": DCResolveResult

  "TCR-Server" --> DID: resolveVC(uri)
  DID --> "TCR-Server": VCResolveResult

  "TCR-Server" --> "BDD-Steps": ResolveResponse
  deactivate "TCR-Server"
```
