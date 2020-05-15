from urllib.request import urlretrieve

from diagrams import Diagram, Cluster, Edge
from diagrams.custom import Custom
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS
from diagrams.aws.network import ELB
from diagrams.aws.storage import S3
from diagrams.k8s.compute import Pod, RS
from diagrams.k8s.controlplane import CM
from diagrams.onprem.client import Client

from diagrams.gcp.storage import GCS

terraform_url = "https://www.terraform.io/assets/images/og-image-8b3e4f7d.png"
terraform_icon = "rabbitmq.png"
urlretrieve(terraform_url, terraform_icon)

dask_icon = "images/dask-icon.png"


with Diagram("Multi-Cloud", show=False):
    terraform = Custom("Terraform", terraform_icon)
    client = Client("Client Notebook")

    with Cluster("AWS"):
        with Cluster("Kubernetes"):
            dask1 = Custom("\nDask", dask_icon)
            worker = RS("Dask Worker")
            worker >> Edge(color="orange") << dask1

        s3 = S3("LENS")

        terraform >> worker
        worker >> s3

    with Cluster("GCP"):
        with Cluster("Kubernetes"):
            dask2 = Custom("\nDask", dask_icon)
            worker2 = RS("Dask Worker")
            worker2 >> Edge(color="orange") << dask2

        gcs = GCS("ERA5")

        terraform >> worker2
        worker2 >> gcs

    client >> dask1
    client >> dask2
