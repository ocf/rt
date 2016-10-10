import time

import pytest
import requests

# TODO: it'd be great if we could auth in our tests...
# Currently these tests aren't overly useful, except to make sure Apache actually starts.


@pytest.fixture(scope='session')
def running_server():
    url = 'http://rt'
    step = 0.1

    for i in range(600):
        time.sleep(step)
        try:
            requests.get(url)
        except requests.exceptions.ConnectionError:
            pass
        else:
            return url
    else:
        raise RuntimeError(
            'Waited {} seconds, but RT did not come up!'.format(i * step),
        )


@pytest.mark.parametrize('route', (
    '/',
    '/Ticket/Display.html?id=4865',
))
@pytest.mark.parametrize('auth', (
    None,
    ('root', 'hunter2'),  # bogus
))
def test_routes_require_auth(running_server, route, auth):
    req = requests.get(
        running_server + route,
        auth=auth,
        headers={'Host': 'rt.ocf.berkeley.edu'},
    )
    assert req.status_code == 401, req.status_code
