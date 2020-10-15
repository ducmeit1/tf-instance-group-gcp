# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "gcp_project" {
  description = "The project to deploy the instance group in"
  type        = string
}

variable "gcp_region" {
  description = "All GCP resources will be launched in this Region."
  type        = string
}

variable "gcp_network" {
  description = "The name of the VPC Network where all resources should be created."
  type        = string
}

variable "gcp_subnetwork" {
  description = "The name of the VPC Subnetwork where all resources should be created."
  type        = string
}

variable "name" {
  description = "The name of the instance group. This variable is used to namespace all resources created by this module."
  type        = string
}

variable "machine_type" {
  description = "The machine type of the Compute Instance to run for each node in the instance group (e.g. n1-standard-1)."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "description" {
  description = "A description of the instance group; it will be added to the Compute Instance Template."
  type        = string
  default     = null
}

variable "tags" {
  description = "The tag name the Compute Instances will uses to open firewall of network."
  type        = list(string)
  default     = []
}

variable "target_size" {
  description = "The number of instance group will be deploy in instance groups"
  type        = number
  default     = 0
}

variable "startup_script" {
  description = "A Startup Script to execute when the server first boots."
  type        = string
  default     = ""
}

variable "shutdown_script" {
  description = "A Shutdown Script to execute when the server recieves a restart or stop event."
  type        = string
  default     = ""
}

variable "source_image" {
  description = "The source image used to create the boot disk for a instance machine."
  type        = string
  default     = ""
}

variable "family_image" {
  description = "The family image used to create the boot disk for a instance machine."
  type        = string
  default     = "debian-9"
}

# Use debian-cloud if use family_image is debian-9
variable "image_project_id" {
  description = "The name of the GCP Project where the image is located. Useful when using a separate project for custom images. If empty, var.gcp_project_id will be used."
  type        = string
  default     = null
}

variable "network_project_id" {
  description = "The name of the GCP Project where the network is located. Useful when using networks shared between projects. If empty, var.gcp_project_id will be used."
  type        = string
  default     = null
}

variable "service_account_scopes" {
  description = "A list of service account scopes that will be added to the Compute Instance Template in addition to the scopes automatically added by this module."
  type        = list(string)
  default     = ["cloud-platform"]
}

variable "instance_group_target_pools" {
  description = "To use a Load Balancer with the instance group, you must populate this value. Specifically, this is the list of Target Pool URLs to which new Compute Instances in the Instance Group created by this module will be added. Note that updating the Target Pools attribute does not affect existing Compute Instances."
  type        = list(string)
  default     = []
}

# Update Policy

variable "instance_group_update_policy_type" {
  description = "The type of update process. You can specify either PROACTIVE so that the instance group manager proactively executes actions in order to bring instances to their target versions or OPPORTUNISTIC so that no action is proactively executed but the update will be performed as part of other actions (for example, resizes or recreateInstances calls)."
  type        = string
  default     = "PROACTIVE"
}

variable "instance_group_update_policy_redistribution_type" {
  description = "The instance redistribution policy for regional managed instance groups. Valid values are: 'PROACTIVE' and 'NONE'. If 'PROACTIVE', the group attempts to maintain an even distribution of VM instances across zones in the region. If 'NONE', proactive redistribution is disabled."
  type        = string
  default     = "PROACTIVE"
}

variable "instance_group_update_policy_minimal_action" {
  description = "Minimal action to be taken on an instance. You can specify either 'RESTART' to restart existing instances or 'REPLACE' to delete and create new instances from the target template. If you specify a 'RESTART', the Updater will attempt to perform that action only. However, if the Updater determines that the minimal action you specify is not enough to perform the update, it might perform a more disruptive action."
  type        = string
  default     = "REPLACE"
}

variable "instance_group_update_policy_max_surge_fixed" {
  description = "The maximum number of instances that can be created above the specified targetSize during the update process. Conflicts with var.instance_group_update_policy_max_surge_percent. See https://www.terraform.io/docs/providers/google/r/compute_region_instance_group_manager.html#max_surge_fixed for more information."
  type        = number
  default     = 3
}

variable "instance_group_update_policy_max_surge_percent" {
  description = "The maximum number of instances(calculated as percentage) that can be created above the specified targetSize during the update process. Conflicts with var.instance_group_update_policy_max_surge_fixed. Only allowed for regional managed instance groups with size at least 10."
  type        = number
  default     = null
}

variable "instance_group_update_policy_max_unavailable_fixed" {
  description = "The maximum number of instances that can be unavailable during the update process. Conflicts with var.instance_group_update_policy_max_unavailable_percent. It has to be either 0 or at least equal to the number of zones. If fixed values are used, at least one of var.instance_group_update_policy_max_unavailable_fixed or var.instance_group_update_policy_max_surge_fixed must be greater than 0."
  type        = number
  default     = 0
}

variable "instance_group_update_policy_max_unavailable_percent" {
  description = "The maximum number of instances(calculated as percentage) that can be unavailable during the update process. Conflicts with var.instance_group_update_policy_max_unavailable_fixed. Only allowed for regional managed instance groups with size at least 10."
  type        = number
  default     = null
}

variable "instance_group_update_policy_min_ready_sec" {
  description = "Minimum number of seconds to wait for after a newly created instance becomes available. This value must be between 0-3600."
  type        = number
  default     = 300
}

# Metadata
variable "custom_metadata" {
  description = "A map of metadata key value pairs to assign to the Compute Instance metadata."
  type        = map(string)
  default     = {}
}

# Disk Settings

variable "preemptible" {
  description = "Enable preemptible for machine."
  type        = bool
  default     = false
}

variable "root_volume_disk_interface" {
  description = "The disk interface to use for attaching this disk; either SCSI or NVME."
  type        = string
  default     = "SCSI"
}

variable "root_volume_disk_size_gb" {
  description = "The size, in GB, of the root disk volume on each machine."
  type        = number
  default     = 30
}

variable "root_volume_disk_type" {
  description = "The GCE disk type. Can be either pd-ssd, local-ssd, or pd-standard."
  type        = string
  default     = "pd-standard"
}

# Service Account Roles

variable "service_account_roles" {
  type        = list(string)
  description = "Service account roles will apply for service account."
  default     = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/compute.osLogin"
  ]
}

variable "members" {
  description = "List of members in the standard GCP form: user:{email}, serviceAccount:{email}, group:{email}."
  type        = list(string)
  default     = []
}