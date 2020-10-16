terraform {
  # This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
  required_version = ">= 0.12"
}

resource "google_service_account" "default" {
    project       = var.gcp_project
    account_id    = format("%s-ig", var.name)
    display_name  = format("Service account for instance group %s", var.name)
}

resource "google_service_account_iam_binding" "default" {
    service_account_id  = google_service_account.default.id
    role                = "roles/iam.serviceAccountUser"
    members             = var.members
}

resource "google_project_iam_member" "default_binding" {
  for_each      = toset(var.service_account_roles)
  project       = var.gcp_project
  role          = each.value
  member        = format("serviceAccount:%s", google_service_account.default.email)
}

data "google_compute_network" "network" {
  project = var.network_project_id != null ? var.network_project_id : var.gcp_project
  name    = var.gcp_network
}

data "google_compute_subnetwork" "subnetwork" {
  project = var.network_project_id != null ? var.network_project_id : var.gcp_project
  name    = var.gcp_subnetwork
  region  = var.gcp_region
}

resource "google_compute_region_instance_group_manager" "default" {
  project             = var.gcp_project
  name                = format("%s-ig", var.name)

  base_instance_name  = var.name
  region              = var.gcp_region

  version {
    instance_template = google_compute_instance_template.default.self_link
  }

  # Instance group would be a stateful instance group, so the update strategy used to roll out a new GCE Instance Template must be
  # a rolling update.
  update_policy {
    type                         = var.instance_group_update_policy_type
    instance_redistribution_type = var.instance_group_update_policy_redistribution_type
    minimal_action               = var.instance_group_update_policy_minimal_action
    max_surge_fixed              = var.instance_group_update_policy_max_surge_fixed
    max_surge_percent            = var.instance_group_update_policy_max_surge_percent
    max_unavailable_fixed        = var.instance_group_update_policy_max_unavailable_fixed
    max_unavailable_percent      = var.instance_group_update_policy_max_unavailable_percent
    min_ready_sec                = var.instance_group_update_policy_min_ready_sec
  }

  target_pools = var.instance_group_target_pools
  target_size  = var.target_size

  depends_on = [
    google_compute_instance_template.default
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_template" "default" {
  project           = var.gcp_project
  region            = var.gcp_region
  name              = var.instance_template_name
  description       = var.description

  machine_type         = var.machine_type
  
  tags                    = var.tags
  metadata_startup_script = var.startup_script
  metadata = merge(
    {
      # The Terraform Google provider currently doesn't support a `metadata_shutdown_script` argument so we manually
      # set it here using the instance metadata.
      "shutdown-script" = var.shutdown_script
      "enable-oslogin"  = "TRUE"
    },
    var.custom_metadata,
  )

  scheduling {
    automatic_restart   = var.preemptible == true ? false : true
    on_host_maintenance = "MIGRATE"
    preemptible         = var.preemptible
  }

  disk {
    boot         = true
    auto_delete  = true
    device_name  = "persistent-disk-0"
    interface    = var.root_volume_disk_interface
    mode         = "READ_WRITE"
    labels       = null
    type         = "PERSISTENT"
    source_image = data.google_compute_image.image.self_link
    disk_size_gb = var.root_volume_disk_size_gb
    disk_type    = var.root_volume_disk_type
  }

  network_interface {
    network            = data.google_compute_network.network.self_link
    subnetwork         = data.google_compute_subnetwork.subnetwork.self_link
    subnetwork_project = var.network_project_id != null ? var.network_project_id : var.gcp_project
    # This is the way to workaround adding external IP address if enable
    dynamic "access_config" {
      for_each = var.enable_pubic_ip ? [""] : []
      content {}
    }
  }

  service_account {
    email = google_service_account.default.email
    scopes = var.service_account_scopes
  }

  # Per Terraform Docs (https://www.terraform.io/docs/providers/google/r/compute_instance_template.html#using-with-instance-group-manager),
  # we need to create a new instance template before we can destroy the old one. Note that any Terraform resource on
  # which this Terraform resource depends will also need this lifecycle statement.
  lifecycle {
    create_before_destroy = true
  }
}

# This is a workaround for a provider bug in Terraform v0.11.8. For more information please refer to:
# https://github.com/terraform-providers/terraform-provider-google/issues/2067.
data "google_compute_image" "image" {
  name    = var.source_image != "" ? var.source_image : null
  family  = var.source_image == "" ? var.family_image : null
  project = var.image_project_id != null ? var.image_project_id : var.gcp_project
}