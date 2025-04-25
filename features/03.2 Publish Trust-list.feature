@tspa
Feature: Trust Framework Configuration
  allow the creation of trust frameworks,
  the creation and configuration of DIDs with well-known did configurations,
  instantiation of trust lists,
  the envelopment of trust lists in Verifiable Credentials with proof and
  configuring the enveloped VCs in the service end point of DID Documents.

  Background:
    Given TSPA Keycloak is up
      And TSPA Server is up
      And input Alias|Text|Description provided
        | Alias          | Text                         | Description |
        | storge         | local                        | TF_DOMAIN_NAME:TRAIN_ENV:dev-with-docker-compose |
        | Storage        | Local                        | TF_DOMAIN_NAME:TRAIN_ENV:dev-with-docker-compose |

        | Storge         | Local                        | TF_DOMAIN_NAME:TRAIN_ENV:jenkins-train           |
        | storge         | local                        | TF_DOMAIN_NAME:TRAIN_ENV:jenkins-train           |
        | tf-domain-name | trust.train1.xfsc.dev        | TF_DOMAIN_NAME:TRAIN_ENV:jenkins-train           |

        | tf-domain-name | trust.train1.xfsc.dev        | TF_DOMAIN_NAME:TRAIN_ENV:dev-use-train           |
        | storage        | local                        | TF_DOMAIN_NAME:TRAIN_ENV:dev-use-train           |
        | Storage        | Local                        | TF_DOMAIN_NAME:TRAIN_ENV:dev-use-train           |
        | usa-pointer    | usa-pointer.{tf-domain-name} |                                                  |
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
    And input json as alias TrustServiceStatusList-Company-A provided
      # language=json
    """
    {
        "TrustServiceProvider": {
            "UUID": "8271fcbf-0622-4415-b8b1-34ad74215dc6",
            "TSPName": "CompanyaA Gmbh",
            "TSPTradeName": "CompanyaA Gmbh",
            "TSPInformation": {
                "Address": {
                    "ElectronicAddress": "info@companya.de",
                    "PostalAddress": {
                        "City": "Stuttgart",
                        "Country": "DE",
                        "PostalCode": "11111",
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
                        "ServiceTypeIdentifier": "string",
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
        }
    }
    """
    And input json as alias TrustServiceProvider-XYZ provided
    # language=json
    """
    {
        "TrustServiceProvider": {
            "UUID": "8271fcbf-0622-4415-b8b1-34ad74215dc6",
            "TSPName": "XYZ Gmbh",
            "TSPTradeName": "XYZ Gmbh",
            "TSPInformation": {
                "Address": {
                    "ElectronicAddress": "info@companya.de",
                    "PostalAddress": {
                        "City": "Siegen",
                        "Country": "DE",
                        "PostalCode": "11111",
                        "State": "BW",
                        "StreetAddress1": "Starstr",
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
                        "ServiceTypeIdentifier": "string",
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
        }
    }
    """

  Scenario: [1] Initial TrustList with XML Pointer:USA
    Given saved Keycloak token
      And alias valid-XML in aliases' context
     When create Trust List with XML payload for pointer usa-pointer with valid-XML
     Then get http 201:Created code
      And requests response content exact json match
      # language=json
      """
      {
        "message": "Trust-list initially created and stored in XML format",
        "status": 201
      }
      """

  Scenario: [2] TSP publish
    Given saved Keycloak token
      And alias TrustServiceStatusList-Company-A in aliases' context
     When publish TSP pointer usa-pointer with TrustServiceStatusList-Company-A
     Then get http 201:Created code
      And requests response content exact json match
      # language=json
      """
      {
         "message": "TSP published for {usa-pointer}.",
         "status": 201
      }
      """

  Scenario: [3] TSP Already exists
    Given saved Keycloak token
      And alias TrustServiceStatusList-Company-A in aliases' context
     When publish TSP pointer usa-pointer with TrustServiceStatusList-Company-A
     Then get http 400:Bad Request
      And requests response content exact json match
      # language=json
      """
      {
        "error": "TSP can't publish : TSP with UUID 8271fcbf-0622-4415-b8b1-34ad74215dc6 already exists.",
        "status": 400
      }
      """

  Scenario: [4] Update TSP
    Given saved Keycloak token
      And alias TrustServiceStatusList-Company-A in aliases' context
     When update TSP pointer/tsp_id usa-pointer/8271fcbf-0622-4415-b8b1-34ad74215dc6 with TrustServiceProvider-XYZ
     Then get http 200:Success code
      And requests response content exact json match
      # language=json
      """
      {
         "message": "TSP update for {usa-pointer} with UUID :8271fcbf-0622-4415-b8b1-34ad74215dc6",
         "status":200
       }
       """

  Scenario: [5] Delete TSP
    Given saved Keycloak token
      And alias TrustServiceStatusList-Company-A in aliases' context
     When delete TSP pointer/tsp_id usa-pointer/8271fcbf-0622-4415-b8b1-34ad74215dc6
     Then get http 200:Success code
      And requests response content exact json match
      # language=json
      """
      {
         "message": "TSP removed form {usa-pointer} for UUID: 8271fcbf-0622-4415-b8b1-34ad74215dc6",
         "status": 200
       }
       """

  @teardown
  Scenario: [6] Tear Down Remove usa-pointer Trust List
    Given saved Keycloak token
     When remove Trust List usa-pointer
     Then get http 200:Success code
      And requests response content exact json match
      # language=json
      """
      {
         "message": "Successfully! Trust-list: '{usa-pointer}' deleted from {storage} store.",
         "status":200
       }
       """