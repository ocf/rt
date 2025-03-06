from tkinter.filedialog import Directory
from transpire.resources import Deployment, Ingress, Secret, Service
from transpire.utils import get_image_tag

from kubernetes import client

name = "rt"
auto_sync = True

def objects():
    svc = Service(
        name = "rt",
        selector = {
            'app': name,
        },
        port_on_pod = 80,
        port_on_svc = 80,
        # fill rest later..
    )
    dep = Deployment(
        name = "rt",
        image = get_image_tag("rt"),
        ports = [ 80 ],
    )

    ing = Ingress.from_svc(
        svc = svc,
        host = "//rt.ocf.berkeley.edu",
        path_prefix = "/",
    )
    sec = Secret(
        name = "keycloak-secret",
        string_data = {
            'secret': '',
            'encryption_key': '',
        }
    )

    # set the volumes in the Deployment
    dep.obj.spec.template.spec.volumes = [
        client.V1Volume(
            name = "secrets",
            host_path = { "path": "/opt/share/kubernetes/secret/rt", "type": "Directory" }
        ),
    ]
    # also set the container used in deployment
    dep.obj.spec.template.spec.containers[0].name = "rt-nginx"
    dep.obj.spec.template.spec.containers[0].env = [
        client.V1EnvVar(
            name = "SERVER_NAME",
            value = "rt.ocf.berkeley.edu",
        ),
        client.V1EnvVar(
            name = "CLIENT_SECRET",
            value_from = client.V1EnvVarSource(
                secret_key_ref = client.V1SecretKeySelector(key = "secret", name = sec.name)
            )
        ),
        client.V1EnvVar(
            name = "ENCRYPTION_KEY",
            value_from = client.V1EnvVarSource(
                secret_key_ref = client.V1SecretKeySelector(key = "encryption_key", name = sec.name)
            )
        )
    ]
    dep.obj.spec.template.spec.containers[0].volume_mounts = [
        { "name": "secrets", "mountPath": "/opt/share/secrets/rt" },
    ]

    # and finally set deployment's dns settings.
    dep.obj.spec.template.spec.dns_policy = "ClusterFirst"
    dep.obj.spec.template.spec.dns_config = {"searches": ["ocf.berkeley.edu"]}

    # build all objects and yield.
    yield svc.build()
    yield dep.build()
    yield ing.build()
    yield sec.build()
