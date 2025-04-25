@tcr
Feature: Testing the TCR Clients
  This functionality MUST allow for the resolution of the Trust List to find the issuer details in.

  To save space and to avoid distracting we will use the below **terms**.

  **TCR**
    *Trusted Content Resolver*.
  **Pointers**
    *Trust Framework Pointers*.
  **TL**
    *Trust List*.

  See also Sequence-Diagrams.md to comprehend integration with external components DNS and DID.

  Background: Interfaces are running
    Given that TCR is running
      And TCR has DNSSEC enabled
      And DID Resolver is running
      And input Alias|Text|Description provided
      | Alias          | Text                         | Description                            |
      | tf-domain-name | trust.train1.xfsc.dev        | TF_DOMAIN_NAME:TRAIN_ENV:dev-use-train |
      | storage        | local                        | TF_DOMAIN_NAME:TRAIN_ENV:dev-use-train |
      | Storage        | Local                        | TF_DOMAIN_NAME:TRAIN_ENV:dev-use-train |

      | tf-domain-name | trust.train1.xfsc.dev        | TF_DOMAIN_NAME:TRAIN_ENV:jenkins-train |
      | storage        | local                        | TF_DOMAIN_NAME:TRAIN_ENV:jenkins-train |
      | Storage        | Local                        | TF_DOMAIN_NAME:TRAIN_ENV:jenkins-train |

      | alice          | alice.{tf-domain-name}       |                                        |
      | issuer-Y       | https://www.federation1.com/ |                                        |

  @succeed
  Scenario: Trust Discovery succeeds direct on Server
    Given Default DNS configured in TCR
      And input pointers provided
      """
      {alice}
      """
      And pointers are `configured` in DNS
      And input issuer `{issuer-Y}` provided
      And no input Endpoint Types provided
     When resolve with server
     Then get http 200:Success code
      And requests response content exact json match
      # language=json
      """
      {
        "trustSchemePointers": [
            {
                "pointer": "{alice}",
                "dids": [
                    "did:web:essif.iao.fraunhofer.de"
                ],
                "error": null
            }
        ],
        "resolvedResults": [
            {
                "did": "did:web:essif.iao.fraunhofer.de",
                "resolvedDoc": {
                    "document": {
                        "@context": [
                            "https://www.w3.org/ns/did/v1",
                            "https://w3id.org/security/suites/jws-2020/v1"
                        ],
                        "id": "did:web:essif.iao.fraunhofer.de",
                        "verificationMethod": [
                            {
                                "id": "did:web:essif.iao.fraunhofer.de#owner",
                                "type": "JsonWebKey2020",
                                "controller": "did:web:essif.iao.fraunhofer.de",
                                "publicKeyJwk": {
                                    "kty": "OKP",
                                    "crv": "Ed25519",
                                    "x": "yaHbNw6nj4Pn3nGPHyyTqP-QHXYNJIpkA37PrIOND4c"
                                }
                            },
                            {
                                "id": "did:web:essif.iao.fraunhofer.de#test",
                                "type": "JsonWebKey2020",
                                "controller": "did:web:essif.iao.fraunhofer.de",
                                "publicKeyJwk": {
                                    "crv": "P-256",
                                    "kid": "test",
                                    "kty": "EC",
                                    "x": "IglrRKSINwyxro6sT4WKy-mowDW2io3b3jL9LML8a-A",
                                    "y": "IQ8l61-wV0mH4ND_O-hEcr-8SY1u8EivybLeMH3a_bM"
                                }
                            }
                        ],
                        "service": [
                            {
                                "id": "did:web:essif.iao.fraunhofer.de#gx-trust-list-issuer",
                                "type": "gx-trust-list-issuer",
                                "serviceEndpoint": "http://fed1-tfm:8080/tspa-service/tspa/v1/workshop-test.federation1.train/vc/trust-list"
                            },
                            {
                                "id": "did:web:essif.iao.fraunhofer.de#gx-trust-list-issuer-federation2",
                                "type": "gx-trust-list-issuer-federation2",
                                "serviceEndpoint": "http://fed2-tfm:8080/tspa-service/tspa/v1/workshop-test.federation2.train/vc/trust-list"
                            },
                            {
                                "id": "did:web:essif.iao.fraunhofer.de#gx-trust-list-issuer-public-xml",
                                "type": "gx-trust-list-issuer-public-xml",
                                "serviceEndpoint": "https://tspa.train1.xfsc.dev/tspa-service/tspa/v1/{alice}/vc/trust-list"
                            },
                            {
                                "id": "did:web:essif.iao.fraunhofer.de#gx-trust-list-issuer-public-json",
                                "type": "gx-trust-list-issuer-public-json",
                                "serviceEndpoint": "https://tspa.train1.xfsc.dev/tspa-service/tspa/v1/bob.{tf-domain-name}/vc/trust-list"
                            }
                        ],
                        "authentication": [
                            "did:web:essif.iao.fraunhofer.de#owner"
                        ],
                        "assertionMethod": [
                            "did:web:essif.iao.fraunhofer.de#owner"
                        ]
                    },
                    "endpoints": [
                        {
                            "vcUri": "https://tspa.train1.xfsc.dev/tspa-service/tspa/v1/{alice}/vc/trust-list",
                            "tlUri": "https://tspa.train1.xfsc.dev/tspa-service/tspa/v1/{alice}/trust-list",
                            "trustList": {
                                "UUID": "8271fcbf-0622-4415-b8b1-34ad74215dc6",
                                "TSPName": "CompanyaA Gmbh",
                                "TSPTradeName": "CompanyaA Gmbh",
                                "TSPInformation": {
                                    "Address": {
                                        "ElectronicAddress": "info@companya.de",
                                        "PostalAddress": {
                                            "City": "Stuttgart",
                                            "Country": "DE",
                                            "PostalCopy": "11111",
                                            "State": "BW",
                                            "StreetAddress1": "Hauptsr",
                                            "StreetAddress2": "071"
                                        }
                                    },
                                    "TSPCertificationList": {
                                        "TSPCertification": [
                                            {
                                                "Type": "ISO:9001",
                                                "Value": "4356546745"
                                            },
                                            {
                                                "Type": "EU-VAT",
                                                "Value": "4356546745"
                                            }
                                        ]
                                    },
                                    "TSPEntityIdentifierList": {
                                        "TSPEntityIdendifier": [
                                            {
                                                "Type": "vLEI",
                                                "Value": "3453654764"
                                            },
                                            {
                                                "Type": "VAT",
                                                "Value": "3453654764"
                                            }
                                        ]
                                    },
                                    "TSPInformationURI": "string"
                                },
                                "TSPServices": {
                                    "TSPService": [
                                        {
                                            "ServiceName": "Federation Notary",
                                            "ServiceTypeIdentifier": "{issuer-Y}",
                                            "ServiceCurrentStatus": "string",
                                            "StatusStartingTime": "string",
                                            "ServiceDefinitionURI": "string",
                                            "ServiceDigitalIdentity": {
                                                "DigitalId": {
                                                    "X509Certificate": "sgdhfgsfhdsgfhsgfs",
                                                    "DID": "did:web:essif.iao.fraunhofer.de"
                                                }
                                            },
                                            "AdditionalServiceInformation": {
                                                "ServiceBusinessRulesURI": "string",
                                                "ServiceGovernanceURI": "string",
                                                "ServiceIssuedCredentialTypes": {
                                                    "CredentialType": [
                                                        {
                                                            "Type": "string"
                                                        },
                                                        {
                                                            "Type": "string"
                                                        }
                                                    ]
                                                },
                                                "ServiceContractType": "string",
                                                "ServicePolicySet": "string",
                                                "ServiceSchemaURI": "string",
                                                "ServiceSupplyPoint": "string"
                                            }
                                        }
                                    ]
                                }
                            },
                            "vcVerified": true
                        }
                    ],
                    "didVerified": true
                },
                "error": null
            }
        ]
      }
      """

  # Scenario: Error case 4** if we send wrong payload, is not reasonable to test it yet