from pathlib import Path

from transpire.resources import Deployment, Ingress, Secret, Service
from transpire.types import ContainerRegistry, Image
from transpire.utils import get_image_tag


name = "rt"
auto_sync = True

def images():
    yield Image(name="rt", path=Path("/"), registry=ContainerRegistry("ghcr"))

def objects():
    dep = Deployment(
        name="rt",
        image=get_image_tag("rt"),
        ports=[80],
    )

    svc = Service(
        name="rt",
        selector=dep.get_selector(),
        port_on_pod=80,
        port_on_svc=80,
    )

    ing = Ingress.from_svc(
        svc=svc,
        host="rt.ocf.berkeley.edu",
        path_prefix="/",
    )
    sec = Secret(
        name="secret",
        string_data={
            'client-cert.pem': '',
            'client-private-key.pem': '',
            'healthcheck.passwd': '',
            'idp-metadata.xml': '',
            'rt-db': '',
            'sp-metadata.xml': '',
        }
    )

    sec_env = Secret(
        name="keycloak-env",
        string_data={
            'CLIENT_SECRET': '',
            'ENCRYPTION_KEY': '',
        }
    )

    # set the volumes in the Deployment

    dep.obj.spec.template.spec.volumes = [
        {"name": "secrets", "secret": {"secretName": "secret"}},
    ]
    
    dep.obj.spec.template.spec.containers[0].volume_mounts = [
        {"name": "secrets", "mountPath": "/opt/share/secrets/rt"},
    ]

    dep.obj.spec.template.spec.containers[0].env = [
        {"name": "SERVER_NAME", "value": "rt.ocf.berkeley.edu"},
    ]
    
    # also set the container used in deployment
    dep.obj.spec.template.spec.containers[0].name = "rt-nginx"
    dep.obj.spec.template.spec.containers[0].volume_mounts = [
        { "name": "secrets", "mountPath": "/opt/share/secrets/rt" },
    ]

    # and finally set deployment's dns settings.
    dep.obj.spec.template.spec.dns_policy = "ClusterFirst"
    dep.obj.spec.template.spec.dns_config = {"searches": ["ocf.berkeley.edu"]}

    dep.pod_spec().with_secret_env("keycloak-env")

    # build all objects and yield.
    yield svc.build()
    yield dep.build()
    yield ing.build()
    yield sec.build()
    yield sec_env.build()
