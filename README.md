# Provision Managed Instance Group on GCP with Terraform

This module will help provision an managed instance group on GCP with Terraform

This module will:

- Create a instance template
- Create a managed instance group with created instance template
- Adding default service account, and roles for service account

## Usages

```hcl
module "instance-group" {
    source                              = "github.com/ducmeit1/tf-instance-group-gcp"
    gcp_project                         = "driven-stage-269911"
    gcp_region                          = "asia-southeast1"
    gcp_network                         = "gcp-network"
    gcp_subnetwork                      = "gcp-subnetwork"`
    name                                = "my-instance-group"
    tags                                = "my-instance-group"
    description                         = "my instance group have 3 instances installed ubuntu 1804 os"
    machine_type                        = "n1-standard-1"
    source_image                        = "ubuntu-1804-lts"
    target_size                         = 3
    startup_script                      = "gs://my-gcs-bucket/scripts/startup-script.sh"
    shutdown_script                     = "gs://my-gcs-bucket/scripts/shutdown-script.sh"
    root_volume_disk_size_gb            = 50
    root_volume_disk_type               = "pd-ssd"
    members                             = ["user:collabrator@gmail.com"]
}
```

```shell
terraform plan
terraform apply --auto-approve
```