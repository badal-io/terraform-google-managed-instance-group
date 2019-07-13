/******************************************
	PROJECT ID (if not passed through)
 *****************************************/
data "google_client_config" "default" {}

locals {
  project-id = "${length(var.project) > 0 ? var.project : data.google_client_config.default.project}"
}

resource "google_compute_instance_template" "default" {
  project      = "${local.project-id}"
  name_prefix  = "${var.name}-instance-template"
  machine_type = "${var.machine_type}"

  region = "${var.region}"

  tags = "${concat(list("allow-ssh"), var.target_tags)}"

  labels = "${var.instance_labels}"

  can_ip_forward = "${var.can_ip_forward}"

  service_account {
    email  = "${var.service_account_email}"
    scopes = "${var.service_account_scopes}"
  }

  disk {
    auto_delete   = "${lookup(var.main_disk, "auto_delete", true)}"
    boot          = true
    source_image  = "${lookup(var.main_disk, "source_image", "projects/debian-cloud/global/images/family/debian-9")}"
    device_name   = "${lookup(var.main_disk, "device_name", null)}"
    mode          = "${lookup(var.main_disk, "device_name", "READ_WRITE")}"
    type          = "${lookup(var.main_disk, "type", "PERSISTENT")}"
    disk_name     = "${lookup(var.main_disk, "disk_name", null)}"
    disk_type     = "${lookup(var.main_disk, "type", "pd-ssd")}"
    disk_size_gb  = "${lookup(var.main_disk, "disk_size_gb", null)}"
  }
  
  dynamic "disk" {
    for_each = [for d in var.additional_disks: {
      # auto_delete - (Optional) Whether or not the disk should be auto-deleted. This defaults to true.
      auto_delete = lookup(d, "auto_delete", true)
      # device_name - (Optional) A unique device name that is reflected into the /dev/ tree of a Linux operating system running within the instance. If not specified, the server chooses a default device name to apply to this disk.
      device_name = lookup(d, "device_name", null)
      # disk_name - (Optional) Name of the disk. When not provided, this defaults to the name of the instance.
      disk_name = lookup(d, "disk_name", null)
      # mode - (Optional) The mode in which to attach this disk, either READ_WRITE or READ_ONLY. If you are attaching or creating a boot disk, this must read-write mode.
      mode = lookup(d, "mode", "READ_WRITE")
      # source - (Required if source_image not set) The name (not self_link) of the disk (such as those managed by google_compute_disk) to attach.
      source = d.source
      # disk_type - (Optional) The GCE disk type. Can be either "pd-ssd", "local-ssd", or "pd-standard".
      disk_type = lookup(d, "disk_type", "pd-ssd")
      # disk_size_gb - (Optional) The size of the image in gigabytes. If not specified, it will inherit the size of its base image.
      disk_size_gb = lookup(d, "disk_size_gb", null)
      #type - (Optional) The type of GCE disk, can be either "SCRATCH" or "PERSISTENT".
      type = lookup(d, "type", "PERSISTENT")
    }]

    content {
      auto_delete   = disk.value.auto_delete
      boot          = disk.value.boot
      device_name   = disk.value.device_name
      disk_name     = disk.value.disk_name
      mode          = disk.value.mode
      source        = disk.value.source
      disk_type     = disk.value.disk_type
      disk_size_gb  = disk.value.disk_size_gb
      type          = disk.value.type
    }
  }

  dynamic "network_interface" {
    for_each = [for n in var.interfaces: {
      network            = lookup(n, "network", null)
      subnetwork         = lookup(n, "subnetwork", null)
      network_ip         = lookup(n, "network_ip", null)
      nat_ip             = lookup(n, "nat_ip", null)
      network_tier       = lookup(n, "network_tier", "PREMIUM")
    }]

    content {
      network            = network_interface.value.network
      subnetwork         = network_interface.value.subnetwork
      network_ip         = network_interface.value.network_ip
      access_config {
        nat_ip           = network_interface.value.nat_ip
        network_tier     = network_interface.value.network_tier
      }
    }
  }

  metadata = "${var.metadata}"

  metadata_startup_script = "${var.startup_script}"

  scheduling {
    preemptible         = "${var.scheduling["preemptible"]}"
    automatic_restart   = "${var.scheduling["automatic_restart"]}"
    on_host_maintenance = "${var.scheduling["on_host_maintenance"]}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_health_check" "default" {
  project      = "${local.project-id}"
  name         = "${var.name}-health-check"
  description  = "${var.hc_description}"

  check_interval_sec  = "${var.hc_check_interval}"
  healthy_threshold   = "${var.hc_healthy_threshold}"
  timeout_sec         = "${var.hc_timeout}"
  unhealthy_threshold = "${var.hc_unhealthy_threshold}"

  dynamic "http_health_check" {
    for_each = [for h in var.http_health_check: {
      host          = lookup(h, "host", null)
      request_path  = lookup(h, "request_path", "/")
      response      = lookup(h, "response", null)
      port          = lookup(h, "port", "80")
      proxy_header  = lookup(h, "proxy_header", "NONE")

    }]

    content {
      host         = http_health_check.value.host
      request_path = http_health_check.value.request_path
      response     = http_health_check.value.response
      port         = http_health_check.value.port
      proxy_header = http_health_check.value.proxy_header
    }
  }

  dynamic "https_health_check" {
    for_each = [for h in var.https_health_check: {
      host          = lookup(h, "host", null)
      request_path  = lookup(h, "request_path", "/")
      response      = lookup(h, "response", null)
      port          = lookup(h, "port", "443")
      proxy_header  = lookup(h, "proxy_header", "NONE")

    }]

    content {
      host         = https_health_check.value.host
      request_path = https_health_check.value.request_path
      response     = https_health_check.value.response
      port         = https_health_check.value.port
      proxy_header = https_health_check.value.proxy_header
    }
  }

  dynamic "tcp_health_check" {
    for_each = [for h in var.tcp_health_check: {
      request       = lookup(h, "request", null)
      response      = lookup(h, "response", null)
      port          = lookup(h, "port", "443")
      proxy_header  = lookup(h, "proxy_header", "NONE")

    }]

    content {
      request      = tcp_health_check.value.request
      response     = tcp_health_check.value.response
      port         = tcp_health_check.value.port
      proxy_header = tcp_health_check.value.proxy_header
    }
  }

  dynamic "ssl_health_check" {
    for_each = [for h in var.ssl_health_check: {
      request       = lookup(h, "request", null)
      response      = lookup(h, "response", null)
      port          = lookup(h, "port", "443")
      proxy_header  = lookup(h, "proxy_header", "NONE")

    }]

    content {
      request      = ssl_health_check.value.request
      response     = ssl_health_check.value.response
      port         = ssl_health_check.value.port
      proxy_header = ssl_health_check.value.proxy_header
    }
  }
}

resource "google_compute_region_instance_group_manager" "default" {
  project = "${local.project-id}"

  name        = "${var.name}-igm"
  description = "${var.igm_description}"

  base_instance_name = "${var.name}"
  instance_template  = "${google_compute_instance_template.default.self_link}"
  region             = "${var.region}"

  wait_for_instances = "${var.wait_for_instances}"

  target_pools = "${var.target_pools}"

  dynamic "named_port" {
    for_each = [for np in var.named_port: {
      name = np.name
      port = np.port
    }]

    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }

  target_size = "${var.igm_target_size}"
}