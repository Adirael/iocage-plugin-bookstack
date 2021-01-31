# Experimental

This plugin is experimental. It seems to work, but pull requests are welcome.

# Install

Clone this repository on your FreeNAS / TrueNAS core server, then run the following command to create a new jail with it.

```
iocage fetch -g https://github.com/Adirael/iocage-plugin-bookstack -P bookstack.json --name bookstack dhcp="on"
``` 

If your installation was done by manually downloading the plugin files, set the plugin_repository property to this repo like

```
iocage set plugin_repository=ttps://github.com/Adirael/iocage-plugin-bookstack bookstack
```

to revieve updates.
