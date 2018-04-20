# NYU Archivesspace DO Plugin
***


This is an ArchivesSpace plugin that extends the ArchivesSpace API to allow real time Digital Object look ups.

This plugin was developed against ArchivesSpace v1.5.1 by [Hudson Molonglo](https://github.com/hudmol/composers) for New York University with generous funding from the Mellon Foundation.

**How to Install**

$ cd /path/to/archivesspace/plugins

$ git clone https://github.com/NYULibraries/Archivesspace-DO-Plugin

Enable the plugin by editing the file in config/config.rb: AppConfig[:plugins] = ['some_exisiting plugin', 'composers']

Add a proxy for your backend url in config/config.rb: AppConfig[:backend_proxy_url] = "http://example.com:8089"
