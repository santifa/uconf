# uconf.sh

`uconf` is a simple configuration management for dot files.
The name stands for user configuration and is designed to backup, restore and
versioning your personal configuration files.

## Example

Let's start with some examples by creating a new configuration and saving them.

    uconf create zsh ~/.zshrc ~/.zshrc.local
    uconf save zsh
    uconf vcs add zsh
    
The first line creates a new configuration which is called `zsh` and consists of the files `~/.zshrc` and `~/.zshrc.local`. The second lines saves and third one adds the configuration to version control.  
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

Then export the uconf home directory (should end with a `/`)
within your `.bashrc` or `.zshrc` like: 

    export CFG_HOME=<some dir>
    
Integrate a vcs with shell variables:

    export CFG_VCS_A="git add"
    export CFG_VCS_C="git commit -m"
    export CFG_VCS_Push="git push"
    export CFG_VCS_Pull="git pull"
    export CFG_VCS_S="git status"
    # default doc name: Readme.md
    export CFG_DOC=Some_other_name.text
   
Now `uconf` is ready to store your dotfiles.

## Command line interface

The main idea is to leverage the shell utilities for the configuration
management. Your local dot files are bundled under a certain configuration
name. This name denotes also the folder which contains the files belonging
to that configuration. This folder is stored along others within the uconf
home directory. Version control is loosly integrated as the commands are just
aliases linked to the appropriate vcs  commands.

Invoke `uconf` with:

    uconf.sh <cmd> <cfg> <additional_args>
    
`<cfg>` refers to the configuration name. Also `<cfg>`
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
* `vcs`: Main command for version control
    + `add <cfg>`: Add a configuration for later commit.
    + `commit <msg>`: Commit configurations with a Message.
    + `status`: Show the vcs state.
    + `push|pull`: Self-explaining
    
## Remarks

Provide pathes either from your home directory (`~/`) or as absolute values.   

## Why not something else?

There are many other management systems for user configuration out there. So why another?
When I worked through them to decide which I would use they all didn't fit in my expectations.  

* no heavy configuration management for a plethora of machines
* no higher language such as python, perl or mixtures of languages
* no tight integration of a specific versioning system
* no symlink (can break some programs)
* only plain `sh`
* not 1k lines of code
