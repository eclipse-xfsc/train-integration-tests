import parse
from parse_type import TypeBuilder
from behave import register_type


@parse.with_pattern(r"[0-9a-z][-0-9a-z]+[0-9a-z]")
def parse_pointer_alias(text: str) -> str:
    return text


register_type(
    TrustFrameworkPointerAlias=parse_pointer_alias,
    TrustFrameworkPointerAliases=TypeBuilder.with_many(parse_pointer_alias)
)
