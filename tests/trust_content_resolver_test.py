"""
Testing TrustedContentResolver
"""
import pytest

from eu.xfsc.bdd.train.components.tcr.client import Client


def test_resolve_validate_host():
    """
    Given invalid host name for Trusted Content Resolver
     When create the model
     Then Value Error have to be raised before calling the Trusted Content Resolver
    """
    with pytest.raises(ValueError,
                       match="Input should be a valid URL, relative URL without a base"):
        Client(host="wrong_host")
