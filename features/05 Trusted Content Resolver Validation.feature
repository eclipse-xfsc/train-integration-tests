Feature: Trust Content Resolver Validation
  - validate the output of the trust discovery functionality of the Trusted Content Resolver
  - validate the association of DID with a well-known DID configuration
  - validate the integrity of the VC
  - validate the issuer details from the trust lists extracted from service endpoints
  - integrate by TRAIN client libraries (go, java, js, py)

  See also Sequence-Diagrams.md to comprehend integration with external component DID.

  To save space and to avoid distracting we will use the below **terms**.

  **TCR**
    *Trusted Content Resolver*.
  **TL**
    *Trust List*.

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
  Scenario: TCR server Validate succeeded
    Given Default DNS configured in TCR
      And input issuer `{issuer-Y}` provided

      And input DID `did:web:essif.iao.fraunhofer.de` provided
      # And input DID `did:web:essif.not.existing` provided

      And input endpoints provided
      """
      https://essif.iao.fraunhofer.de/files/trustlist/federation1.test.train.trust-scheme.de.json
      """
     When validate with the server
     Then get http 200:Success code

  @succeed
  Scenario Outline: TCR client Validate succeeded
    Given <TCR Client> installed
    And input issuer `{issuer-Y}` provided
      And input DID `did:web:essif.iao.fraunhofer.de` provided
      And input endpoints provided
      """
      https://essif.iao.fraunhofer.de/files/trustlist/federation1.test.train.trust-scheme.de.json
      """
     When validate with the client
     Then validation response is valid
      And did is Verified
    Examples:
      | DNS         | TCR Client |
      | Default DNS | Python     |
      | Default DNS | Java       |
      | Default DNS | JavaScript |
      | Default DNS | Golang     |

  @failed
  Scenario Outline: TCR client Validate failed with 501
    Given <TCR Client> installed
      And input issuer `{issuer-Y}` provided
      And input DID `did:web:without.did.configuration` provided
      And input endpoints provided
      """
      https://essif.iao.fraunhofer.de/files/trustlist/federation1.test.train.trust-scheme.de.json
      """

    # Important (!) we expect to fail with 510 Not Extended, to be fixed with proper test data in ZM and TSPA
     When may fail validate with the client
     Then validation response content exact match regexp
     """
     <Match>
     """
       #Then validation response is valid
        # isVerified: false
      #And did isn't Verified

      Examples:
      | DNS         | TCR Client | Match              |
      | Default DNS | Python     | \nHTTP response body: \{"code":"did_error","message":"uniresolver.ResolutionException"\}\n\n$ |
      | Default DNS | Java       | 510 Not Extended   |
      | Default DNS | JavaScript | ^$ |
      | Default DNS | Golang     | ^510.*\n$ |
