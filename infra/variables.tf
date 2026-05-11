variable "proxmox_api_url" {
  type = string
}
variable "proxmox_token_id" {
  type = string
}
variable "proxmox_token_secret" {
  type      = string
  sensitive = true
}
variable "proxmox_node" {
  type    = string
  default = "pve-1"
}
variable "template_name" {
  type    = string
  default = "ubuntu-22.04-template"
}
variable "network_bridge" {
  type    = string
  default = "vmbr2"
}
variable "gateway" {
  type    = string
  default = "192.168.192.5"
}
variable "storage" {
  type    = string
  default = "local-zfs"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for VM access"
}
# test terraform workflow
