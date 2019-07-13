variable "project" {
  description = "The project to deploy to, if not set the default provider project is used."
  default     = ""
}

variable "machine_type" {
  description = "Machine type for the VMs in the instance group."
  default     = "f1-micro"
}

variable "main_disk" {
  description = "This is for the main disk that will load your image"
  type        = "map"
  default = {
    # auto_delete - (Optional) Whether or not the disk should be auto-deleted. This defaults to true.
    auto_delete   = true
    # device_name - (Optional) A unique device name that is reflected into the /dev/ tree of a Linux operating system running within the instance. If not specified, the server chooses a default device name to apply to this disk.
    device_name   = null
    # disk_name - (Optional) Name of the disk. When not provided, this defaults to the name of the instance.
    disk_name     = null
    # source_image - (Required if source not set) The image from which to initialize this disk. This can be one of: the image's self_link, projects/{project}/global/images/{image}, projects/{project}/global/images/family/{family}, global/images/{image}, global/images/family/{family}, family/{family}, {project}/{family}, {project}/{image}, {family}, or {image}.
    source_image  = "projects/debian-cloud/global/images/family/debian-9"
    # mode - (Optional) The mode in which to attach this disk, either READ_WRITE or READ_ONLY. If you are attaching or creating a boot disk, this must read-write mode.
    mode          = "READ_WRITE"
    # disk_type - (Optional) The GCE disk type. Can be either "pd-ssd", "local-ssd", or "pd-standard".
    disk_type     = "pd-ssd"
    # disk_size_gb - (Optional) The size of the image in gigabytes. If not specified, it will inherit the size of its base image.
    disk_size_gb  = null
    #type - (Optional) The type of GCE disk, can be either "SCRATCH" or "PERSISTENT".
    type          = "PERSISTENT"
  }
}

variable "additional_disks" {
  description = "List of Map consisting of Disk block"
  type        = "list"
  default     = []
}

variable "name" {
  description = "Name of the managed instance group."
}

variable "can_ip_forward" {
  description = "Allow ip forwarding."
  default     = false
}

variable "instance_labels" {
  description = "Labels added to instances."
  type        = "map"
  default     = {}
}

variable "metadata" {
  description = "Map of metadata values to pass to instances."
  type        = "map"
  default     = {}
}

variable "startup_script" {
  description = "Content of startup-script metadata passed to the instance template."
  default     = ""
}

variable "interfaces" {
  description = "List of Map consisting of network interface"
  type        = "list"
  default     = []
}

variable "region" {
  description = "Region for cloud resources."
  default     = "us-central1"
}

variable "scheduling" {
  description = "Map outlining schedule settings"
  type        = "map"
  default     = {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }
}

variable "service_account_email" {
  description = "The email of the service account for the instance template."
  default     = "default"
}

variable "service_account_scopes" {
  description = "List of scopes for the instance template service account"
  type        = "list"

  default = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/devstorage.full_control",
  ]
}

variable "target_tags" {
  description = "Tag added to instances for firewall and networking."
  type        = "list"
  default     = ["allow-service"]
}

# Health Checks
variable "hc_check_interval" {
  description = "How often (in seconds) to send a health check"
  default     = "5"
}

variable "hc_description" {
  description = "Descripton for health check"
  default     = "Health Check - Provisioned by Terraform"
}

variable "hc_healthy_threshold" {
  description = "A so-far unhealthy instance will be marked healthy after this many consecutive successes"
  default     = "2"
}

variable "hc_timeout" {
  description = "How long (in seconds) to wait before claiming failure. The default value is 5 seconds. It is invalid for timeoutSec to have greater value than checkIntervalSec"
  default     = "5"
}

variable "hc_unhealthy_threshold" {
  description = "A so-far healthy instance will be marked unhealthy after this many consecutive failures"
  default     = "2"
}

variable "http_health_check" {
  description = "http health check. Pass map with keys as described at https://www.terraform.io/docs/providers/google/r/compute_health_check.html#timeout_sec"
  type        = "list"
  default     = []
}

variable "https_health_check" {
  description = "https health check. Pass map with keys as described at https://www.terraform.io/docs/providers/google/r/compute_health_check.html#timeout_sec"
  type        = "list"
  default     = []
}

variable "tcp_health_check" {
  description = "tcp health check. Pass map with keys as described at https://www.terraform.io/docs/providers/google/r/compute_health_check.html#timeout_sec"
  type        = "list"
  default     = []
}

variable "ssl_health_check" {
  description = "ssl health check. Pass map with keys as described at https://www.terraform.io/docs/providers/google/r/compute_health_check.html#timeout_sec"
  type        = "list"
  default     = []
}

# Instance Group Manager
variable "igm_description" {
  description = "An optional textual description of the instance group manager."
  default = "Instance group Manager - Provisioned by Terraform"
}

variable "named_port" {
  description = "The named port configuration."
  type        = "list"
  default = []
}

variable "igm_target_size" {
  description = "The target number of running instances for this managed instance group. This value should always be explicitly set unless this resource is attached to an autoscaler, in which case it should never be set"
  default = 0
}

variable "wait_for_instances" {
  description = "Wait for all instances to be created/updated before returning"
  default = false
}

variable target_pools {
  description = "The target load balancing pools to assign this group to."
  type        = "list"
  default     = []
}