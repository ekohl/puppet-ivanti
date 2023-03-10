# ivanti

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with ivanti](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with ivanti](#beginning-with-ivanti)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)
1. [Miscellaneous notes - How the Ivanti BASH script works](#miscellaneous)

## Description

This module attempts to install the Ivanti Landesk agent on Red Hat linux
and its derivitives

## Setup

### Setup Requirements **OPTIONAL**

Currently, this module requres an exteral YUM/DNF repository to be configured
so that the ivanti RPM packages can be installed via the native Puppet
package manager.

This module does not yet manage the local firewall.

This module does a poor job of managing the sudoers configuration for the
landesk user.  Eventually, the Ivanti module will automatically configure
sudoers via an appropriate Puppet module.

### Beginning with ivanti

Minimum parameters needed are @core_certificate and core_fqdn.

## Usage

Include usage examples for common use cases in the **Usage** section. Show your
users how to use your module to solve problems, and be sure to include code
examples. Include three to five examples of the most important or common tasks a
user can accomplish with your module. Show users how to accomplish more complex
tasks that involve different types, classes, and functions working in tandem.

## Limitations

Currently, there is an issue with permission handling on certificate files
located in $install_dir/var/cbaroot/broker.  If these files are not owned by
the landesk:landes user/group, then 'vulscan' daemon will fail.


## Miscellaneous **Optional**

I developed this module by hacking away at that Ivanti nixconfig.sh file and
looking over the debug logs.  Brain dumps and haphazard notes can be found in
the [brain dump](docs/brain_dump.md) documentation.
