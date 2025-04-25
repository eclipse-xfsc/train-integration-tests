@zm
Feature: Publishing the Trust Framework and the DID in the DNS Zone file

  **Trust Framework Pointer**
    will be referred bellow as just **pointer**.
  **DNS Zone Manager
    may be referred as just **ZM Server**

  Background:
   Given ZM Keycloak is up
     And DNS Zone Manager Server is up
     And input Alias|Text|Description provided
        | Alias                           | Text                       | Description                                      |
        | tf-domain-name                  | trust.train1.xfsc.dev      | TF_DOMAIN_NAME:TRAIN_ENV:jenkins-train           |
        | tf-domain-name                  | dev-idm.iao.fraunhofer.de  | TF_DOMAIN_NAME:TRAIN_ENV:dev-with-docker-compose |
        | tf-domain-name                  | trust.train1.xfsc.dev      | TF_DOMAIN_NAME:TRAIN_ENV:dev-use-train           |
        # europe
        | 1-europe                        | 1-europe.{tf-domain-name}  |                |
        | 2-germany                       | 2-germany.{tf-domain-name} |                |
        | 2-france                        | 2-france.{tf-domain-name}  |                |
        | 2-spain                         | 2-spain.{tf-domain-name}   |                |
        # america
        | 1-america                       | 1-america.{tf-domain-name} |                |
        | 2-usa                           | 2-usa.{tf-domain-name}     |                |
        | 2-mexico                        | 2-mexico.{tf-domain-name}  |                |
        | 2-canada                        | 2-canada.{tf-domain-name}  |                |
        # edge cases
        | not-valid-because-out-of-domain | x.y.z.de                   |                |
        | not-existed                     | some-value                 |                |

  Scenario: [01] Display Zone Manager data not allowed when not authenticated
    When requests from ZM server all the zones
    Then get http 403:401 Unauthorized
     And requests response content exact json match
     # language=json
     """
     {
         "title": "401 Unauthorized",
         "description": "Authorization as bearer token required"
     }
     """

  @auth
  Scenario: [02] Auth (get token from identity provider)
    When fetch Keycloak token
    Then save Keycloak token

  @clean-all
  Scenario: [03] Clean all zones / Tear Up
    Given saved Keycloak token
      And all zones deleted in ZM successfully ..
     When requests from ZM server all the zones
     Then get http 200:Success code
      And requests response content exact json match
      # language=json
      """
      {
          "zones": [{
              "id": 1,
              "apex": "{tf-domain-name}",
              "schemes": []
          }]
      }
      """

  Scenario: [04] Create `1-europe` Continent Pointer
    Given saved Keycloak token
      And Trust Framework Pointers not exists: 1-europe
     When creating pointers: 1-europe into 1-europe
     Then get http 200:Success code

  Scenario: [05] Override Continent Pointer
    Given saved Keycloak token
     When creating pointers: 1-europe into 1-europe
     Then get http 200:Success code

  Scenario: [06] Add A Country to Continent Pointer
    Given saved Keycloak token
      And Trust Framework Pointers: 1-europe
      And Trust Framework Pointers not exists: 2-germany
     When creating pointers: 1-europe, 2-germany, 2-spain into 1-europe
     Then get http 200:Success code

  Scenario: [07] Create Continent with countries in one requests
    Given saved Keycloak token
      And Trust Framework Pointers not exists: 1-america, 2-usa, 2-mexico, 2-canada
     When creating pointers: 1-america, 2-usa, 2-canada, 2-mexico into 1-america
     Then get http 200:Success code

  Scenario: [08] Read existing pointer from europe
    Given saved Keycloak token
     When requests pointer 1-europe
     Then get http 200:Success code
      And requests response content exact json match
      # language=json
      """
      {
          "schemes": [
              "1-europe.{tf-domain-name}",
              "2-germany.{tf-domain-name}",
              "2-spain.{tf-domain-name}"
          ]
      }
      """

  Scenario: [09] Read existing pointer from america
    Given saved Keycloak token
     When requests pointer 1-america
     Then get http 200:Success code
      And requests response content exact json match
      # language=json
      """
      {
          "schemes": [
              "1-america.{tf-domain-name}",
              "2-canada.{tf-domain-name}",
              "2-mexico.{tf-domain-name}",
              "2-usa.{tf-domain-name}"
          ]
      }
      """

  Scenario Outline: [10] Try to read not existing pointers
    Given saved Keycloak token
     When requests pointer <Pointer>
     Then get http 200:Success code
      And requests response content exact json match
      # language=json
      """
      {
          "schemes": []
      }
      """

    Examples:
      | Pointer     |
      # only europe is a pointer
      | 2-germany   |
      | 2-spain     |
      | 2-france    |
      # only america is a pointer
      | 2-usa        |
      | 2-mexico     |
      | 2-germany    |
      # edge cases
      | not-existed  |

  Scenario: [11] Read did for a invalid trust scheme
    Given saved Keycloak token
     When requests DID did:web:not-valid-because-out-of-domain pointer not-valid-because-out-of-domain.testtrain.trust-scheme.de creation
     Then get http 404:Not Found
      And requests response content exact json match
      # language=json
      """
      {
        "title": "not-valid-because-out-of-domain.testtrain.trust-scheme.de is not a valid trust scheme"
      }
      """

  Scenario Outline: [12] Create DID for Pointers
    Given saved Keycloak token
     When requests DID <DID> pointer <Pointer> creation
     Then get http 200:Success code

    Examples:
      | Pointer    | DID                          |
      | 1-europe   | did:web:some-did-for-europe  |
      | 2-germany  | did:web:some-did-for-germany |
      | 1-america  | did:web:some-did-for-america |
      | 2-usa      | did:web:some-did-for-usa     |
      | 2-mexico   | did:web:some-did-for-mexico  |

  Scenario Outline: [13] Can Read DID for Pointers
    Given saved Keycloak token
     When requests DID for pointer <Pointer>
     Then get http 200:Success code
      And requests response content exact json match
      # language=json
      """
      {
          "did": "<DID>"
      }
      """

    Examples:
      | Pointer   | DID                           |
      | 1-europe  | did:web:some-did-for-europe   |
      | 2-germany | did:web:some-did-for-germany  |
      | 1-america  | did:web:some-did-for-america |
      | 2-usa      | did:web:some-did-for-usa     |
      | 2-mexico   | did:web:some-did-for-mexico  |

  Scenario Outline: [14] Can't Read DID for Pointers
    Given saved Keycloak token
     When requests DID for pointer <Pointer>
     Then get http 200:Success code
      And requests response content exact text match
      """
      []
      """

    Examples:
      | Pointer                         |
      # europe
      | 2-france                        |
      | 2-spain                         |
      # america
      | 2-canada                        |
      | not-existed                     |
      | not-valid-because-out-of-domain |

  Scenario Outline: [15] Try to Remove a not existed DID for pointer
    Given saved Keycloak token
     When remove from ZM server DIDs pointer <Pointer>
     Then get http 404:Not Found

    Examples:
      | Pointer                         |
      # europe
      | 2-france                        |
      | 2-spain                         |
      # america
      | 2-canada                        |
      | not-existed                     |
      | not-valid-because-out-of-domain |

  @teardown
  Scenario Outline: [16] Remove DID from existing Pointers
    Given saved Keycloak token
     When remove from ZM server DIDs pointer <Pointer>
     Then get http 204:No Content code

    Examples:
      | Pointer   |
      | 1-america |
      | 2-usa     |
      | 2-mexico  |

  @teardown
  Scenario Outline: [17] Remove existing Pointers / Tear Down
    Given saved Keycloak token
     When remove from ZM server pointer <Pointer>
     Then get http 204:No Content code

    Examples:
      | Pointer   |
      | 1-europe  |
      | 1-america |

  @teardown
  Scenario Outline: [18] Failed to read pointer after deletion
    Given saved Keycloak token
     When requests pointer <Pointer>
     Then get http 200:Success code
      And requests response content exact json match
      # language=json
      """
      {"schemes": []}
      """

    Examples:
      | Pointer   |
      | 1-europe  |
      | 1-america |

  @teardown
  Scenario: [19] Pointer deletion in [18] will trigger DID recursive deletion
    > See Scenario [13]
    Given saved Keycloak token
     When requests DID for pointer 2-germany
     Then get http 200:Success code
      And requests response content exact text match
      """
      []
      """

# concurrent write requests are locked by database (sqlite)
#  Scenario: [20] 00024-A5_An error is provided if a record is in progress by the operator
# #low priority
#  @manual
#    Given the fully environment setup
#    And an update or create record is still in progress by the operator
#    When a next create/update request of trust framework is sent
#    Then an error `409 Conflict` is provided
