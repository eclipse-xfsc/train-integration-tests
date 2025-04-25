@tspa
Feature: Trust List Management
  allow CRUD (create, read, update, delete) operations on the trust list at the Trusted Data Store

  Background:
    Given TSPA Keycloak is up
      And TSPA Server is up
      And input Alias|Text|Description provided
      | Alias                           | Text                                   | Description                                      |
      | tf-domain-name                  | trust.train1.xfsc.dev                  | TF_DOMAIN_NAME:TRAIN_ENV:jenkins-train           |
      | storage                         | local                                  | TF_DOMAIN_NAME:TRAIN_ENV:jenkins-train           |
      | Storage                         | Local                                  | TF_DOMAIN_NAME:TRAIN_ENV:jenkins-train           |

      | tf-domain-name                  | trust.train1.xfsc.dev                  | TF_DOMAIN_NAME:TRAIN_ENV:dev-use-train           |
      | storage                         | local                                  | TF_DOMAIN_NAME:TRAIN_ENV:dev-use-train           |
      | Storage                         | Local                                  | TF_DOMAIN_NAME:TRAIN_ENV:dev-use-train           |

      | tf-domain-name                  | dev-idm.iao.fraunhofer.de              | TF_DOMAIN_NAME:TRAIN_ENV:dev-with-docker-compose |
      | storage                         | local                                  | TF_DOMAIN_NAME:TRAIN_ENV:dev-with-docker-compose |
      | Storage                         | Local                                  | TF_DOMAIN_NAME:TRAIN_ENV:dev-with-docker-compose |

      | 1-europe                        | 1-europe.{tf-domain-name}              |             |
      | xml-germany                     | xml-germany.{tf-domain-name}           |             |
      | json-france                     | json-france.{tf-domain-name}           |             |
      And input text as alias valid-XML provided
      # language=xml
      """<?xml version="1.0" encoding="UTF-8" ?>
      <TrustServiceStatusList>
          <FrameworkInformation>
              <TSLVersionIdentifier>1</TSLVersionIdentifier>
              <TSLSequenceNumber>1</TSLSequenceNumber>
              <TSLType>http://TRAIN/TrstSvc/TrustedList/TSLType/federation1-POC</TSLType>
              <FrameworkOperatorName>
                  <Name>Federation 1</Name>
              </FrameworkOperatorName>
              <FrameworkOperatorAddress>
                  <PostalAddresses>
                      <PostalAddress>
                          <StreetAddress>Hauptsrasse</StreetAddress>
                          <Locality>Stuttgart</Locality>
                          <PostalCode>70563</PostalCode>
                          <CountryName>DE</CountryName>
                      </PostalAddress>
                  </PostalAddresses>
                  <ElectronicAddress>
                      <URI>mailto:admin@federation1.de</URI>
                  </ElectronicAddress>
              </FrameworkOperatorAddress>
              <FrameworkName>
                  <Name>federation1.train.trust-Framework.de</Name>
              </FrameworkName>
              <FrameworkInformationURI>
                  <URI>https://TRAIN/interoperability/federation-Directory</URI>
              </FrameworkInformationURI>
              <FrameworkAuditURI>
                  <URI>https://TRAIN/interoperability/Audit</URI>
              </FrameworkAuditURI>
              <FrameworkTypeCommunityRules>
                  <URI>https://TrustFramework_TRAIN.example.com/en/federation1-dir-rules.html</URI>
              </FrameworkTypeCommunityRules>
              <FrameworkScope>EU</FrameworkScope>
              <PolicyOrLegalNotice>
                  <TSLLegalNotice>The applicable legal framework for the present trusted list is TBD. Valid legal notice text will be created.</TSLLegalNotice>
              </PolicyOrLegalNotice>
              <ListIssueDateTime>2023-12-15T00:00:00Z</ListIssueDateTime>
          </FrameworkInformation>
      </TrustServiceStatusList>
      """
      And input json as alias valid-JSON provided
      # language=json
      """
      {
        "TrustServiceStatusList": {
            "FrameworkInformation": {
                "TSLVersionIdentifier": "1",
                "TSLSequenceNumber": "1",
                "TSLType": "http://TRAIN/TrstSvc/TrustedList/TSLType/federation1-POC",
                "FrameworkOperatorName": {
                    "Name": "Federation 1"
                },
                "FrameworkOperatorAddress": {
                    "PostalAddresses": {
                        "PostalAddress": [
                            {
                                "StreetAddress": "Hauptsrasse",
                                "Locality": "Stuttgart",
                                "PostalCode": "70563",
                                "CountryName": "DE"
                            }
                        ]
                    },
                    "ElectronicAddress": {
                        "URI": "mailto:admin@federation1.de"
                    }
                },
                "FrameworkName": {
                    "Name": "federation1.train.trust-Framework.de"
                },
                "FrameworkInformationURI": {
                    "URI": "https://TRAIN/interoperability/federation-Directory"
                },
                "FrameworkAuditURI": {
                    "URI": "https://TRAIN/interoperability/Audit"
                },
                "FrameworkTypeCommunityRules": {
                    "URI": "https://TrustFramework_TRAIN.example.com/en/federation1-dir-rules.html"
                },
                "FrameworkScope": "EU",
                "PolicyOrLegalNotice": {
                    "TSLLegalNotice": "The applicable legal framework for the present trusted list is   TBD. Valid legal notice text will be created."
                },
                "ListIssueDateTime": "2023-12-15T00:00:00Z"
            }
        }
      }
      """

  Scenario: [01] Can not create pointer when Unauthorized
    When TSPA create pointer 1-europe
    Then get http 401:401 Unauthorized
     And requests response content exact json match
     # language=json
     """
     """

  @auth
  Scenario: [02.1] Auth (get token from identity provider)
    When fetch Keycloak token
    Then save Keycloak token

  Scenario: [02.2] Create Europe pointer
    Given saved Keycloak token
     When TSPA create pointer 1-europe
     Then get http 201:Created code
     And requests response content exact json match
      """
      {
        "message": "Trust-framework created for 1-europe.{tf-domain-name}",
        "status": 201
      }
      """

  Scenario: [03.1] Attach a DID to Europe as DID:WEB
    Given saved Keycloak token
     When requests DID did:web:essif.iao.fraunhofer.de pointer 1-europe creation in TSPA Server
     Then get http 201:Created code
     And requests response content exact json match
      """
      {
        "message": "URI(DID) published for 1-europe.{tf-domain-name}",
        "status": 201
      }
      """

  Scenario: [03.2] Attach a DID to Europe as DID:KEY
    Given saved Keycloak token
     When requests DID did:key:some-value pointer 1-europe creation in TSPA Server
     Then get http 201:Created code
      And requests response content exact json match
      # language=json
      """
      {
        "message": "URI(DID) published for 1-europe.{tf-domain-name}",
        "status": 201
      }
      """

  Scenario: [03.3] Attach a DID to Europe as DID:WEB with invalid Well-known verification
    Given saved Keycloak token
     When requests DID did:web:invalid.subdomain.some-invalid-domain.com pointer 1-europe creation in TSPA Server
     Then get http 400:Bad Request
      And requests response content exact json match
      # language=json
      """
      {
        "message": "Well-known verification failed.",
        "status": 400
      }
      """


  Scenario: [03.4] DID Method not supported
    Given saved Keycloak token
     When requests DID did:jwk:eyJrdHkiOiJPS1AiLCJjcnYiOiJFZDI1NTE5IiwieCI6Ikp2R3VNb0w0NXZFemlJNHFMeXJCU0tsVzFVUW9xUU5SQU9KZS1QRTV5ZVUifQ pointer 1-europe creation in TSPA Server
     Then get http 400:Bad Request
     # language=json
     """
     {
        "message": "DID Method not supported, expecting methods are definded in the 'application.yml'!",
        "status": 400
     }
     """

  @teardown
  Scenario: [04] Detach Europe's DID Pointer
    Given saved Keycloak token
     When remove from TSPA server DIDs pointer 1-europe
     Then get http 200:Success code

  @teardown
  Scenario: [05] Remove existing Europe Pointer
    Given saved Keycloak token
     When remove from TSPA Server pointer 1-europe
     Then get http 200:Success code

  Scenario: [06.1] Initial TrustList with invalid XML
    Given saved Keycloak token
     When create Trust List with XML payload for pointer xml-germany with content
     # language=xml
     """
     <bad_xml>invalid</bad_xml>
     """
     Then get http 400:Bad Request
      And requests response content match regexp
      """
      XML validation failed:\s+org.xml.sax.SAXParseException; lineNumber: 1; columnNumber: 10; cvc-elt.1.a: Cannot find the declaration of element 'bad_xml'.
      """

  Scenario Outline: [06.2] Initial TrustList with XML
    Given saved Keycloak token
      And alias valid-XML in aliases' context
     When create Trust List with XML payload for pointer <Pointer> with valid-XML
     Then get http 201:Created code
      And requests response content exact json match
      # language=json
      """
      {
        "message": "Trust-list initially created and stored in XML format",
        "status": 201
      }
      """

    Examples:
      | Pointer     |
      | xml-germany |

  Scenario: [06.3] Upsert TrustList with XML fails
    Given saved Keycloak token
      And alias valid-XML in aliases' context
     When create Trust List with XML payload for pointer xml-germany with valid-XML
     Then get http 400:Bad Request
      And requests response content exact json match
      # language=json
      """
      {
        "error": "File already exist  : {Storage} store; Trustlist is already Existing for xml-germany.{tf-domain-name}",
        "status": 400
      }
      """

  Scenario: [07.1] Initial TrustList with invalid JSON
    Given saved Keycloak token
     When create Trust List with JSON payload for pointer json-france with content
     # language=json
     """
     {"invalid_json": "schema"}
     """
     Then get http 400:Bad Request
      And requests response content match regexp
      """
      JSON validation failed:\s+\$.TrustServiceStatusList: is missing but it is required
      """

  @this
  Scenario: [07.2] Initial TrustList with json-france
    Given saved Keycloak token
      And alias valid-JSON in aliases' context
     When create Trust List with JSON payload for pointer json-france with valid-JSON
     Then get http 201:Created code
      And requests response content exact json match
      # language=json
      """
      {
        "message": "Trust-list initially created and stored in JSON format",
        "status": 201
      }
      """

  Scenario: [07.3] Upsert TrustList with json-france fails
    Given saved Keycloak token
      And alias valid-JSON in aliases' context
     When create Trust List with JSON payload for pointer json-france with valid-JSON
     Then get http 400:Bad Request
      And requests response content exact json match
      # language=json
      """
      {
        "error": "File already exist  : {Storage} store; Trustlist is already Existing for json-france.{tf-domain-name}",
        "status":400
      }
      """

  Scenario: [08.1] Read XML initialized TrustList
    Given saved Keycloak token
     When read Trust List xml-germany
     Then get http 200:Success code
      And requests response content match regexp
      """
      <TrustServiceStatusList>.*
      """

  Scenario: [08.2] Read json-france initialized TrustList
    Given saved Keycloak token
     When read Trust List json-france
     Then get http 200:Success code
      And requests response content match regexp
      """
      "TrustServiceStatusList": \{.*
      """

  Scenario: [09.1] Read XML initialized TrustList as VC
    Given saved Keycloak token
     When read VC xml-germany
     Then get http 200:Success code
      And requests response content exact json match
      # language=json
      """
         {
             "@context": [
            "https://w3id.org/security/suites/ed25519-2020/v1",
            "https://w3id.org/security/suites/jws-2020/v1",
            "https://www.w3.org/2018/credentials/v1"
        ],
        "type": [
            "VerifiableCredential"
        ],
        "id": "did:web:essif.iao.fraunhofer.de#issuer-lists",
        "issuer": "did:web:essif.iao.fraunhofer.de",
        "issuanceDate": "2024-02-26T18:09:27+01:00",
        "expirationDate": "2025-06-15T18:56:59Z",
        "credentialSubject": {
            "id": "uuid:2632367287r82729",
            "trustlisttype": "XML based Trust-lists",
            "trustlistURI": "http://train-tspa-server:16003/tspa-service/tspa/v1/xml-germany.dev-idm.iao.fraunhofer.de/trust-list",
            "hash": "QmQQxvFPh3fWHyAw2AjVwvaUyxaaiH2UmKADvdkV6R71hr"
        },
        "proof": {
            "type": "JsonWebSignature2020",
            "created": "2024-02-26T18:09:27Z",
            "proofPurpose": "assertionMethod",
            "verificationMethod": "did:web:essif.iao.fraunhofer.de#test",
            "jws": "eyJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdLCJhbGciOiJFZERTQSJ9..vIA-Pbnhn24P5m99ilQTrp-53WIppDklo_BJCyJaUaB7Fwy6lCxYqOBb9nyPQx1fy-EhLs-jUgoJvWq_RKqUAw"
        },
        "#": {
          "in": {
            "": [
              {
                "ignore": ["issuanceDate"]
              }
            ],
            "proof": [
              {
                "ignore": ["created", "jws"]
              }
            ],
            "credentialSubject": [
              {
                "ignore": ["trustlistURI"]
              }
            ]
          }
        }
      }
      """

  Scenario: [09.2] Read json-france initialized TrustList as VC
    Given saved Keycloak token
     When read VC json-france
     Then get http 200:Success code
      And requests response content exact json match
      # language=json
      """
      {
        "@context": [
            "https://w3id.org/security/suites/ed25519-2020/v1",
            "https://w3id.org/security/suites/jws-2020/v1",
            "https://www.w3.org/2018/credentials/v1"
        ],
        "type": [
            "VerifiableCredential"
        ],
        "id": "did:web:essif.iao.fraunhofer.de#issuer-lists",
        "issuer": "did:web:essif.iao.fraunhofer.de",
        "issuanceDate": "2024-02-26T18:27:35+01:00",
        "expirationDate": "2025-06-15T18:56:59Z",
        "credentialSubject": {
            "id": "uuid:2632367287r82729",
            "trustlisttype": "JSON based Trust-lists",
            "trustlistURI": "http://train-tspa-server:16003/tspa-service/tspa/v1/json-france.dev-idm.iao.fraunhofer.de/trust-list",
            "hash": "QmUEe6UtgmnPkzWNvUe2GgYywzz4k6HmJteQLTfMjgB86z"
        },
        "proof": {
            "type": "JsonWebSignature2020",
            "created": "2024-02-26T18:27:35Z",
            "proofPurpose": "assertionMethod",
            "verificationMethod": "did:web:essif.iao.fraunhofer.de#test",
            "jws": "eyJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdLCJhbGciOiJFZERTQSJ9..l-8TJxMfuPkH81N2n4P3w3UnhLOsvGhq_dNwo0NUDn1Ay3Ecut28e5AbM82ya-NoLxMZc7kIn7Xlhm8LxIpaCA"
        },
        "#": {
          "in": {
            "": [
              {
                "ignore": ["issuanceDate"]
              }
            ],
            "proof": [
              {
                "ignore": ["created", "jws"]
              }
            ],
            "credentialSubject": [
              {
                "ignore": ["trustlistURI", "hash"]
              }
            ]
          }
        }
      }
      """

  @teardown
  Scenario Outline: [10.1] Remove Trust List
    Given saved Keycloak token
     When remove Trust List <Pointer>
     Then get http 200:Success code
      And requests response content exact json match
      # language=json
      """
      {
        "message": "Successfully! Trust-list: '<Pointer>.{tf-domain-name}' deleted from {storage} store.",
        "status":200
      }
      """

    Examples:
      | Pointer     |
      | xml-germany |
      | json-france |

  @teardown
  Scenario: [10.2] Remove already deleted Trust List
    Given saved Keycloak token
     When remove Trust List json-france
     Then get http 200:Success code
      And requests response content exact json match
      # language=json
      """
      {
         "message": "Trust list not avalible in {storage} store.",
         "status": 200
      }
      """
