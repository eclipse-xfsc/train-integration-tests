@tcr @tspa
Feature: 04.0 Provision TCR Test Data.feature
  Background: Interfaces are running
    Given TSPA Keycloak is up
      And TSPA Server is up
      And input Alias|Text|Description provided
      | Alias                 | Text                         | Description                            |
      | tf-domain-name        | trust.train1.xfsc.dev        | TF_DOMAIN_NAME:TRAIN_ENV:dev-use-train |
      | storage               | local                        | TF_DOMAIN_NAME:TRAIN_ENV:dev-use-train |
      | Storage               | Local                        | TF_DOMAIN_NAME:TRAIN_ENV:dev-use-train |

      | tf-domain-name        | trust.train1.xfsc.dev        | TF_DOMAIN_NAME:TRAIN_ENV:jenkins-train |
      | storage               | local                        | TF_DOMAIN_NAME:TRAIN_ENV:jenkins-train |
      | Storage               | Local                        | TF_DOMAIN_NAME:TRAIN_ENV:jenkins-train |

      | alice                 | alice.{tf-domain-name}       |                                        |
      | bob                   | bob.{tf-domain-name}         |                                        |
      | issuer-Y              | https://www.federation1.com/ |                                        |
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
        }
      }
      """

  @auth
  Scenario: [A1] Auth (get token from identity provider)
    When fetch Keycloak token
    Then save Keycloak token
  #

  @teardown
  Scenario Outline: [10.1] Remove Trust List
    Given saved Keycloak token
    When remove Trust List <TL>
    Then get http 200:Success code
    Examples:
    | TL    |
    | alice |
    | bob   |

  Scenario: [A2] Initial TrustList with alice
    Given saved Keycloak token
    When create Trust List with XML payload for pointer alice with valid-XML
    Then get http 201:Created code
    And requests response content exact json match
      # language=json
      """
      {
        "message": "Trust-list initially created and stored in XML format",
        "status": 201
      }
      """

  Scenario: [A3] TSP publish
    Given saved Keycloak token
    And alias TrustServiceStatusList-Company-A in aliases' context
    When publish TSP pointer alice with TrustServiceStatusList-Company-A
    Then get http 201:Created code
    And requests response content exact json match
      # language=json
      """
      {
         "message": "TSP published for {alice}.",
         "status": 201
      }
      """

  Scenario: [A4] Create alice pointer
    Given saved Keycloak token
    When TSPA create pointer alice
    Then get http 201:Created code
    And requests response content exact json match
      """
      {
        "message": "Trust-framework created for {alice}",
        "status": 201
      }
      """

  Scenario: [03] Attach a DID to alice as DID:WEB
    Given saved Keycloak token
    When requests DID did:web:essif.iao.fraunhofer.de pointer alice creation in TSPA Server
    Then get http 201:Created code
    And requests response content exact json match
      """
      {
        "message": "URI(DID) published for {alice}",
        "status": 201
      }
      """
