Composers Plugin
-----------------------------------

This is an ArchivesSpace plugin that extends the ArchivesSpace API to allow realtime Digital Object lookups.

This plugin was developed against ArchivesSpace v1.5.1 by Hudson Molonglo for New York University.


# Getting Started

Clone the reposiory from github


  $ cd /path/to/archivesspace/plugins 

  $ git clone https://github.com/NYULibraries/composers

Enable the plugin by editing the file in `config/config.rb`:
  AppConfig[:plugins] = ['some_plugin', 'composers']

Add a proxy for your backend url  in `config/config.rb`:
  AppConfig[:backend_proxy_url] = "http://example.com:8089"


