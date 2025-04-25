"""
Helpers functions for steps in TCR
"""
from typing import Type

import json

import pydantic


def validate_json_with_pydantic(  # pylint: disable=missing-function-docstring
        response: str,
        model: Type[pydantic.BaseModel]) -> pydantic.BaseModel:

    try:
        return model.model_validate_json(response)
    except pydantic.ValidationError:
        try:
            dump = json.dumps(json.loads(response), indent=4)
            print(f"[PRINT:ERROR] {dump}")
        except json.decoder.JSONDecodeError as json_decode_error:
            print(f"[PRINT:ERROR] {json_decode_error=}")
            print(f"[PRINT:ERROR] {response=}")

        raise
