"""
BDD extension for TCR Resolve Response
"""
from typing import Any, Iterable

import json

from eu_xfsc_train_tcr import ResolveResponse  # type: ignore[attr-defined]

from eu.xfsc.bdd.core.models.decentralized_identifiers import Did
from eu.xfsc.bdd.core.models.trust_framework_pointer import \
    TrustFrameworkPointer


class SetEncoder(json.JSONEncoder):
    def default(self, o: Any) -> Any:
        if isinstance(o, set):
            return list(o)
        return json.JSONEncoder.default(self, o)


class ResolveResponseAssert(ResolveResponse):
    """
    Extend ResolveResponse with assert methods
    """

    def log(self) -> str:
        return "\n-------------ResolveResponse::\n" + json.dumps(
            self.model_dump(), cls=SetEncoder, indent=4)

    # pylint: disable=not-an-iterable
    def assert_pointers_are_resolved_with_at_least_one_did(
            self
    ) -> Iterable[tuple[TrustFrameworkPointer, set[Did]]]:
        """
        Assert that all input pointers are resolved with at least one DID.

        :return: input_pointer, resolved_pointer.dids
        """
        if not self.trust_scheme_pointers:
            raise AssertionError("Empty trust_scheme_pointers"
                                 f"\n{self.log()}")

        for resolved_pointer in self.trust_scheme_pointers:
            if not resolved_pointer.dids:
                raise AssertionError(f"Not all pointer resolved with a DID,"
                                     f"\n{self.trust_scheme_pointers=},"
                                     f"\n{self.log()}")

            yield (
                resolved_pointer.pointer,
                set(resolved_pointer.dids)  # type: ignore[arg-type,misc]
            )

    def assert_no_did_resolve(self) -> None:
        """
        No DID Resolve
        """
        if not self.trust_scheme_pointers:
            raise AssertionError("Empty trust_scheme_pointers"
                                 f"\n{self.log()}")

        for resolved_pointer in self.trust_scheme_pointers:
            if resolved_pointer.dids:
                raise AssertionError(f"Some pointer resolved with a DID,"
                                     f"\n{self.trust_scheme_pointers=},"
                                     f"\n{self.log()}")

    def assert_resolved_did_do_have_at_least_one_tl(self) -> None:
        """
        All resolved DID do have at least one TL
        """
        # pylint: disable=too-many-nested-blocks
        for input_pointer, dids in tuple(
                self.assert_pointers_are_resolved_with_at_least_one_did()):

            for did in dids:
                for resolved_did in (self.resolved_results or []):
                    if did == resolved_did.did:
                        if not resolved_did.resolved_doc:
                            raise AssertionError(
                                f"{input_pointer=}/{did=} doesn't have a `resolvedDoc` for TL, "
                                f"\n{self.log()}"
                            )

                        if not resolved_did.resolved_doc.endpoints:
                            raise AssertionError(
                                f"{input_pointer=}/{did=} doesn't have a `endpoints` for TL, "
                                f"\n{self.log()}"
                            )

                        for endpoint in resolved_did.resolved_doc.endpoints:
                            if not endpoint.trust_list:
                                raise AssertionError(
                                    f"{input_pointer=}/{did=} doesn't have a TL, "
                                    f"see:\n {resolved_did.resolved_doc.endpoints},"
                                    f"\n{self.log()}"
                                )
                        break
                else:
                    raise AssertionError(f"{did=} doesn't match any DID from trust scheme pointer, "
                                         f"\n{self.log()}")

    def assert_resolved_did_do_not_have_a_tl(self) -> None:
        """
        All Resolved DID don't have a TL
        """
        for input_pointer, dids in tuple(
                self.assert_pointers_are_resolved_with_at_least_one_did()):

            for did in dids:
                for resolved_did in (self.resolved_results or []):
                    if did == resolved_did.did:
                        if not resolved_did.resolved_doc:
                            break

                        for endpoint in (resolved_did.resolved_doc.endpoints or []):
                            assert endpoint.trust_list, \
                                (f"{input_pointer=}/{did=} have a TL,"
                                 f"\n{resolved_did.resolved_doc.endpoints=}"
                                 f"\n{self.log()}")
                        break
                else:
                    raise AssertionError(f"{did=} doesn't match any DID from trust scheme pointer",
                                         f"\n{self.log()}")


__all__ = ["ResolveResponseAssert"]
