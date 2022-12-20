
variable "config_file" {
  type    = string
  default = "archlinux"
}

variable "cpu" {
  type    = string
  default = "2"
}

variable "disk_size" {
  type    = string
  default = "12000"
}

variable "headless" {
  type    = string
  default = "true"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:de301b9f18973e5902b47bb00380732af38d8ca70084b573ae7cf36a818eb84c"
}

variable "iso_url" {
  type    = string
  default = "https://mirror.csclub.uwaterloo.ca/archlinux/iso/2022.12.01/archlinux-x86_64.iso"
}

variable "name" {
  type    = string
  default = "archlinux"
}

variable "ram" {
  type    = string
  default = "2048"
}

variable "ssh_password" {
  type    = string
  default = "user"
}

variable "ssh_username" {
  type    = string
  default = "user"
}

variable "installer_script" {
  type    = string
  default = "default_setup.sh"
}

source "qemu" "archlinux" {
  accelerator            = "kvm"
  boot_command           = [
    "<enter>",
    "<wait10><wait10><wait10>",
    "curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/arch/${var.installer_script} && chmod +x ${var.installer_script} && ./${var.installer_script} -i {{ .HTTPIP }} -p {{ .HTTPPort }}<enter>"
  ]
  boot_wait              = "1s"
  disk_cache             = "none"
  disk_compression       = true
  disk_discard           = "ignore"
  disk_interface         = "virtio"
  disk_size              = var.disk_size
  format                 = "qcow2"
  headless               = var.headless
  host_port_max          = 2229
  host_port_min          = 2222
  http_directory         = "."
  http_port_max          = 10089
  http_port_min          = 10082
  iso_checksum           = var.iso_checksum
  iso_url                = var.iso_url
  net_device             = "virtio-net"
  output_directory       = "artifacts"
  qemu_binary            = "/usr/bin/qemu-system-x86_64"
  qemuargs               = [["-m", "${var.ram}M"], ["-smp", "${var.cpu}"]]
  shutdown_command       = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  ssh_handshake_attempts = 500
  ssh_password           = var.ssh_password
  ssh_timeout            = "45m"
  ssh_username           = var.ssh_username
  ssh_wait_timeout       = "45m"
}

build {
  sources = ["source.qemu.archlinux"]

  provisioner "shell" {
    execute_command = "{{ .Vars }} bash '{{ .Path }}'"
    inline          = [
      "sudo pacman --noconfirm -Syu ansible ansible-core",
      "ansible-galaxy collection install community.general"
    ]
  }

  provisioner "ansible-local" {
    playbook_dir  = "ansible"
    playbook_file = "ansible/playbook-common.yml"
  }

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E bash '{{ .Path }}'"
    inline          = [
      "echo done"
    ]
  }
}
