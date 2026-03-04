terraform {
  required_version = ">= 1.3.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.50"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = "${var.proxmox_token_id}=${var.proxmox_token_secret}"
  insecure  = true
}

locals {
  nodes = {
    "k8s-master"  = { id = 200, ip = "192.168.192.50" }
    "k8s-worker1" = { id = 201, ip = "192.168.192.51" }
    "k8s-worker2" = { id = 202, ip = "192.168.192.52" }
  }
}

resource "proxmox_virtual_environment_vm" "k8s_nodes" {
  for_each  = local.nodes
  name      = each.key
  vm_id     = each.value.id
  node_name = var.proxmox_node

  clone {
    datastore_id = "local-zfs"
    vm_id        = 9000
    full         = true
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = "local-zfs"
    size         = 25
    interface    = "scsi0"
  }

  network_device {
    bridge = "vmbr2"
    model  = "virtio"
  }

  initialization {
    datastore_id = "local-zfs"
    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = var.gateway
      }
    }
    user_account {
      username = "ubuntu"
      keys     = [file("~/.ssh/id_ed25519.pub")]
    }
  }

  started = true
  on_boot = true

  timeouts {
    create = "10m"
  }

  vga {
    type = "serial0"
  }
}

resource "local_file" "ansible_inventory" {
  depends_on = [proxmox_virtual_environment_vm.k8s_nodes]
  content = templatefile("${path.module}/inventory.tpl", {
    master_ip  = local.nodes["k8s-master"].ip
    worker_ips = {
      "k8s-worker1" = local.nodes["k8s-worker1"].ip
      "k8s-worker2" = local.nodes["k8s-worker2"].ip
    }
  })
  filename = "../ansible/inventory.ini"
}
