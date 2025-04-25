"""
Domain Name System Zone Manager Model
"""
from pydantic import BaseModel

from eu.xfsc.bdd.core.models.trust_framework_pointer import \
    TrustFrameworkPointer


class DomainNameSystemZoneManager(BaseModel):
    """
    Known also as Zone Manager Handler.

    MUST be developed by @Fraunhofer

    See `https://gitlab.eclipse.org/eclipse/xfsc/train/dns-zone-manager`_
    """

    # noinspection PyMethodMayBeStatic
    def is_up(self) -> bool:
        """
        To be implemented
        """
        return True

    def __contains__(self, item: TrustFrameworkPointer) -> bool:
        raise NotImplementedError

    def __getitem__(self, item: str) -> TrustFrameworkPointer:
        raise NotImplementedError

    def create(self) -> None:
        """TODO"""
        raise NotImplementedError
