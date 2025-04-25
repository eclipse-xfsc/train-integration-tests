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
  Scenario Outline: Trust Discovery with <DNS> succeeds
    Given <TCR Client> installed
      And <DNS> configured in TCR
      And input pointers provided
        """
        {alice}
        """
      And pointers are `configured` in DNS
      And input issuer `{issuer-Y}` provided
      And no input Endpoint Types provided
     When resolve with the client
     Then resolved response is valid
      And all input pointers are resolved with at least one DID
      And all resolved DID has a TL

    Examples:
      | DNS         | TCR Client |
      | Default DNS | Python     |
      | Default DNS | Java       |
      | Default DNS | JavaScript |
      | Default DNS | Golang     |
      #| KNOT#1      | Python     |
      #| NSD#1       | Python     |

  @partial-success
  Scenario Outline: Trust Discovery with <DNS> partial-success (empty TL)
    Given <TCR Client> installed
      And <DNS> configured in TCR
      And input pointers provided
        """
        gxfs.test.train.trust-scheme.de
        """
      And pointers are `configured` in DNS
      And input issuer `https://test-issuer.sample.org` provided
      And input Endpoint Types provided
        """
        wrong-typ
        """
      When resolve with the client
      Then resolved response is valid
       And all input pointers are resolved with at least one DID
       And all resolved DID don't have a TL

    Examples:
      | DNS         | TCR Client |
      | Default DNS | Java       |

  Scenario Outline: Trust Discovery with <DNS> fail
    Given <TCR Client> installed
    Given <DNS> configured in TCR
      And input pointers provided
      """
      sausweis.train3.trust-scheme.de
      sausweis.train4.trust-scheme.de
      """
    And pointers are `misconfigured` in DNS
    And input issuer `did:example:123456789abcdefghijk` provided
    When resolve with the client
    Then resolved response is valid
     And no DID resolved

    Examples: DNS Server
      | DNS         | TCR Client |
      | Default DNS | Java       |
