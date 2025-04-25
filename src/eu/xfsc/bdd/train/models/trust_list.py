"""
Trust List Model
"""
from pydantic import BaseModel

from eu.xfsc.bdd.core.models.trust_framework_pointer import \
    TrustFrameworkPointer

_CACHE = None


class TrustList(BaseModel):
    """
    Mocked version of the Trust List

    See `https://gitlab.eclipse.org/eclipse/xfsc/train/tspa`_
    """

    cache: bool = True

    def __len__(self) -> int:
        """
        Check if Trust List is empty `len(trust_list) == 0`

        :status: mocked
        """
        return 0

    @classmethod
    def fetch(cls, cache: bool = True) -> "TrustList":
        """
        Reuse cached instance if fetched previously else fetch from remote

        :param cache: always fetch if set as false
        """
        global _CACHE  # pylint: disable=global-statement

        if cache:
            if _CACHE:
                return _CACHE

        _CACHE = cls()

        return _CACHE

    @property
    def trust_framework_pointers(self) -> set[TrustFrameworkPointer]:
        """
        Extract just trust framework pointers from TL
        """
        return {TrustFrameworkPointer("sausweis.train1.trust-scheme.de")}
