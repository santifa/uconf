# uconf.sh

`uconf` is a simple configuration management for your dotfiles.
The name stands for user configuration and is designed to backup, restore and maybe
versioning your personal configuration files.

## Example

Before explaining the ideas behind, let me show you some examples.  
Let's start by creating a new configuration and saving them.

    uconf create zsh ~/.zshrc ~/.zshrc.local
    uconf save zsh
    uconf commit zsh # not implemented yet
    
The first line creates a new configuration which is called `zsh` and consists of the files `~/.zshrc` and `~/.zshrc.local`. The second lines save the configuration an the third one commits them
into the version control.  
Now some other things:

    uconf rm zsh ~/.zshrc
    uconf add zsh ~/.zprofile

These two lines are removing or adding files to a configuration.

## Installation

Checkout this repo with `$ git clone <path>`.
You can use this script rightaway. A more comfortable way is to
create an alias, copy the script or link this script as stated blow.  

    cp <repo>/uconf /usr/local/bin/uconf
    ln -s /usr/local/bin/uconf <repo>/unconf.sh
    alias -g uconf='<repo>/uconf.sh`

Then export the uconf home directory (should end with a `/`) and 
optional a vcs file within your `.bashrc` or `.zshrc` like: 

    export CFG_HOME=<some dir>
    export CFG_VCS=<vcs file>
    
It is possible to create a documentation for every configuration.
The default doc filename is `Readme.md` but can be changed with `export CFG_DOC=<filename>`. 

Now `uconf` is ready to store your dotfiles.

## Usage

### TODO
The basic idea is the following:  
You local dotfiles are stored in a single folder structure.  
The `CFG_HOME` directory contains all defined configurations.  
A configuration consists of a name (which is used as internal folder name)
and a set of files and/or directories which belongs to the configuration.  
The files can be stored or loaded to/from the configuration.
### TODO

## Command line interface

Invode `uconf` with:

    uconf.sh <cmd> <cfg> <additional_args>
    
`<cfg>` refers to the configuration which is used. Also `<cfg>`
denotes the internal directory name in which the configurations are stored.

All available commands (`<cmd>`) and additional arguments are:

* `help`: Prints a help message similar to this one
* `create <cfg> <files>`: Add a new configuration
  + `<files>`: A list of files which belong to the new configuration

* `add <cfg> <files>`: Add a new configuration
  + `<files>`: A list of files which belong to the new configuration

* `rm <cfg> <files>`: Add a new configuration
  + `<files>`: A list of files which belong to the new configuration
  
* `save <cfg>`: Stores a local configuration into the cfg home
  
* `load <cfg>`: Loads a configuration from the cfg home into the desposited local folder
  
* `status <cfg>`: Show the `.cfg` file for a particular configuration

* `doc <cfg>`: Change the documentation file for a configuration

* `show`: List all configurations and file properties

## Remarks

Provide pathes either from your home directory (`~/`) or as absolute values.  
Further version may contain a possibility to call vcs.  

## Why not something else?

There are many other management systems for user configuration out there. So why another?
When I worked through them to decide which I would use they all didn't fit in my expectations.  

* no heavy configuration management for a plethora of machines
* no higher language such as python, perl or mixtures of languages
* no tight integration of a specific versioning system
* no symlink (can break some programs)
* only plain `sh`
* not 1k lines of code
