# packer-archlinux

Packer image for archlinux

Uses `archinstall` and a custom profile to create an archlinux server image

For more information on profiles see [Scripting your own installation](https://github.com/archlinux/archinstall/#scripting-your-own-installation) on the archinstall README.


## Configuration

`archinstall` uses the files found under `arch/` to select the installer configuration options.

These files are downloaded to the live image and used to execute the installer.

```
arch
|── archinstall_packer.sh
|── default_setup.sh
├── user_configuration.json
├── user_credentials.json
└── user_disk_layout.json
```

`user_configuration.json` - contains the configuration for the installer
`user_credentials.json` - contains default user credentials
`user_disk_layout.json` - change the partition and disk layout configuration

## Artifacts

The artifact generated is a `qcow2` image under `artifacts/packer-archlinux`.
