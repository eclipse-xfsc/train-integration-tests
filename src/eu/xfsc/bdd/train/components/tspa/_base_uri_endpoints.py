"""
Reusable UriEndpoint API for big list og endpoints
"""
from typing import Any

import abc

import pydantic
import requests

from eu.xfsc.bdd.core.defaults import CONNECT_TIMEOUT_IN_SECONDS


class UriEndpoint(pydantic.BaseModel, abc.ABC):  # pylint: disable=missing-class-docstring
    host: pydantic.HttpUrl
    path: str
    CONNECT_TIMEOUT_IN_SECONDS: int = CONNECT_TIMEOUT_IN_SECONDS
    http: requests.Session = requests.Session()

    model_config = pydantic.ConfigDict(arbitrary_types_allowed=True)

    def put(self, *args: Any) -> requests.Response:
        raise NotImplementedError()

    def get(self, *args: Any) -> requests.Response:
        raise NotImplementedError()

    def delete(self, *args: Any) -> requests.Response:
        raise NotImplementedError()

    def patch(self, *args: Any) -> requests.Response:
        raise NotImplementedError()
