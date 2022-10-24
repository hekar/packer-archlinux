# packer-archlinux

Packer image for archlinux

uses `archinstall` to create a vanilla archlinux installation

## Configuration

`archinstall` uses the files found under `arch/` to select the installer configuration options

```
arch
├── user_configuration.json
├── user_credentials.json
└── user_disk_layout.json
```

`user_configuration.json` - 
`user_credentials.json` - 
`user_disk_layout.json` - change the partition and disk layout configuration

## Artifacts

The artifact generated is `artifacts/packer-archlinux`

This is a qemu `qcow2` image.

