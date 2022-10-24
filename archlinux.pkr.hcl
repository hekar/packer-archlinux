
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
  default = "false"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:17fe2053a114f2002efed53b39f740dd9778f5b689c9467a310b2649a80a6bfd"
}

variable "iso_url" {
  type    = string
  default = "https://mirror.csclub.uwaterloo.ca/archlinux/iso/2022.10.01/archlinux-x86_64.iso"
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

source "qemu" "archlinux" {
  accelerator            = "kvm"
  boot_command           = [
    "<enter>",
    "<wait10><wait10><wait10>",
    "cd /<enter><wait>",
    "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/arch/user_credentials.json<enter><wait5>",
    "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/arch/user_configuration.json<enter><wait5>",
    "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/arch/user_disk_layout.json<enter><wait5>",
    "archinstall --config user_configuration.json --creds user_credentials.json --disk_layout user_disk_layout.json --silent && systemctl reboot<enter>"
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
    execute_command = "{{ .Vars }} sudo -E bash '{{ .Path }}'"
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
