# Experimental

This plugin is experimental. It has not been testing at all

# Install

Clone this repository on your FreeNAS server. And run the following command to create a new jail with it. 

```
iocage fetch -P bookstack.json --name bookstack ip4_addr="vnet0|192.168.1.152/24" defaultrouter="192.168.1.1"
``` 