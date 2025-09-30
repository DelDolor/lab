# Packer
https://developer.hashicorp.com/packer

## Azure VM-image
xxx.hcl contains configuration to build image. "source" image is identified by searching the Azure list of virtual machines using packer's image_sku configuration.

```
  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-focal"
  image_sku       = "20_04-lts"
```


## sample
can be found in SEC540 Lab 2.2
