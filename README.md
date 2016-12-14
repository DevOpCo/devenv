# DevEnv

___Consider it "Dev-top" support.___

__Problem__: It doesn't work on your machine.

__Real Problem__: It only works on my machine.

__Truth__: I have no idea how _this_ works

The way Vagrant configurations are managed requires a level of knowledge of systems, and coding, that might not be intuitive to a new developer or someone coming over from one organization to another within a company. This repo is meant as a bootstrapping option for those looking to find consistency and extensibility in order to develop and understand the extensibility of Vagrant. It provides a low risk, low cost option to creating a production-like environment for any given project.

# Requirements

 - Virtualbox
 - Vagrant

Installation and setup the simple way:

## macos
  Install [homebrew](http://brew.sh)

  `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

  Install Virtualbox
  `brew cask install virtualbox`
  Install Vagrant
  `brew cask install vagrant`

## Ubuntu
  - TODO: add Ubuntu installation instructions

## Vagrant

### Getting started

run `source bin/setup.sh` from the root of this repo. This will install RVM, the repo gemset, bundler, and run `bundle install` in your current terminal session. That way, you can get started right away with utilizing this repo.

After running the setup script, you can choose to run `bin/run`, which will output the possible commands configured in the thor scripts:

 - `bin/run configure -e default` copies example files from the `examples/default/` directory and place them in the `config/` directory.
 - `bin/run vagrant -o <ORGANIZATION>` sets the ORGANIZATION environment variable.
 - `bin/run vagrant [-u|-s|-p]` executes `vagrant up|status|provision` respectively

The `Vagrantfile` contains ruby code that will run a `git clone` of the repositories listed in the yaml. These repositories are for configurations and hieradata used in puppet provisioning.

After the VM is provisioned on the first vagrant run, it is advised that you run `vagrant provision` a second time due to how puppet provisions a server.
Now you're ready to get onto the box. Run `vagrant ssh` to verify that you're inside the box as the deploy user.

Vagrant will ask for Administrator privileges in order to modify /etc/exports. To avoid this, follow these [Root Privilege Requirement](https://docs.vagrantup.com/v2/synced-folders/nfs.html) instructions.

## Settings for Platform Development

### Puppet

Provisioning of the vagrant box is managed primarily by puppet. See the `devopco-puppet` repo for specifics. For configuration purposes, see the `devopco-configs` repo for specifics. The `provisors` sections of the `servers.yml` has a list of shell scripts, as well as puppet specific configurations that can be adjusted as needed.

### Plugins

##### Defaults

While `vagrant-auto_network` isn't absolutely necessary, it was included as default to alleviate any need to have the developer remember to set the ip addresses correctly (i.e. in case a developer assigned the same ip address to 2 running instances, which would cause networking conflicts)

###### [vagrant-auto_network](https://github.com/oscar-stack/vagrant-auto_network)

To change the default pool in case there are networking conflicts, change `AutoNetwork.default_pool = '192.168.100.0/24'` to whatever scheme and subnet you need.
If you've run it once, but your change isn't reflecting the new setting, check and remove if necessary `~/.vagrant.d/auto_network/pool.yaml`

###### [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater)

If you don't want to manage your own `/etc/hosts` file, use this plugin. This helps if you're attempting configurations of a fictional cluster, and need to set the servers to a resolvable host (i.e. being able to navigate to an app's web interface via a freindly url).

NB: This is a work in progress, and a labor of love. It is meant to help those that are not familiar with coding to get a head start, it is also managed and maintained by less that experienced individuals with a desire to share knowledge, and learn while they teach. Community input is always welcome.
