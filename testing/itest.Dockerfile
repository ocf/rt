# A MySQL database with RT fixtures loaded.
FROM docker.ocf.berkeley.edu/theocf/debian:jessie

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl \
        python3 \
        python3-pytest \
        python3-requests \
    && rm -rf /var/lib/apt/lists/*

COPY /itest.py /root/
CMD ["py.test-3", "/root/itest.py"]

# vim: ft=Dockerfile
