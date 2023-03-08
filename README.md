# ivanti

Welcome to your new module. A short overview of the generated parts can be found
in the [PDK documentation][1].

The README template below provides a starting point with details about what
information to include in your README.

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with ivanti](#setup)
    * [What ivanti affects](#what-ivanti-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with ivanti](#beginning-with-ivanti)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Briefly tell users why they might want to use your module. Explain what your
module does and what kind of problems users can solve with it.

This should be a fairly short description helps the user decide if your module
is what they want.

## Setup

### What ivanti affects **OPTIONAL**

If it's obvious what your module touches, you can skip this section. For
example, folks can probably figure out that your mysql_instance module affects
their MySQL instances.

If there's more that they should know about, though, this is the place to
mention:

* Files, packages, services, or operations that the module will alter, impact,
  or execute.
* Dependencies that your module automatically installs.
* Warnings or other important notices.

### Setup Requirements **OPTIONAL**

If your module requires anything extra before setting up (pluginsync enabled,
another module, etc.), mention it here.

If your most recent release breaks compatibility or requires particular steps
for upgrading, you might want to include an additional "Upgrading" section here.

### Beginning with ivanti

The very basic steps needed for a user to get the module up and running. This
can include setup steps, if necessary, or it can be an example of the most basic
use of the module.

## Usage

Include usage examples for common use cases in the **Usage** section. Show your
users how to use your module to solve problems, and be sure to include code
examples. Include three to five examples of the most important or common tasks a
user can accomplish with your module. Show users how to accomplish more complex
tasks that involve different types, classes, and functions working in tandem.

## Reference

This section is deprecated. Instead, add reference information to your code as
Puppet Strings comments, and then use Strings to generate a REFERENCE.md in your
module. For details on how to add code comments and generate documentation with
Strings, see the [Puppet Strings documentation][2] and [style guide][3].

If you aren't ready to use Strings yet, manually create a REFERENCE.md in the
root of your module directory and list out each of your module's classes,
defined types, facts, functions, Puppet tasks, task plans, and resource types
and providers, along with the parameters for each.

For each element (class, defined type, function, and so on), list:

* The data type, if applicable.
* A description of what the element does.
* Valid values, if the data type doesn't make it obvious.
* Default value, if any.

For example:

```
### `pet::cat`

#### Parameters

##### `meow`

Enables vocalization in your cat. Valid options: 'string'.

Default: 'medium-loud'.
```

## Limitations

In the Limitations section, list any incompatibilities, known issues, or other
warnings.

## Development

In the Development section, tell other users the ground rules for contributing
to your project and how they should submit their work.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You can also add any additional sections you feel are
necessary or important to include here. Please use the `##` header.

[1]: https://puppet.com/docs/pdk/latest/pdk_generating_modules.html
[2]: https://puppet.com/docs/puppet/latest/puppet_strings.html
[3]: https://puppet.com/docs/puppet/latest/puppet_strings_style.html



RPMs for RHEL family:
http://{{ ivanti_server }}/ldlogon/unix/linux/baseclient64.tar.gz
http://{{ ivanti_server }}/ldlogon/unix/linux/vulscan64.tar.gz
http://{{ ivanti_server }}/ldlogon/unix/linux/lsminstall.sh


# YUM repository for RHEL7/RHEL8
cat > /etc/yum.repos.d/ivanti.repo << EOF
[ivanti]
name=Ivanti Resource Management
baseurl="http://nfiv-man-repo02.nfii.com/repos/ivanti/$releasever/$basearch"
enabled=1
gpgcheck=1
gpgkey=http://nfiv-man-repo02.nfii.com/repos/ivanti/RPM-GPG-KEY-IVANTI
EOF

# check "cert stuff" whatever that means:
http://<hostname>:9595/allowed/ldping



# This probably needs to be run as the landesk user or at least
# the ./var/cbaroot/broker/broker/* and ./var/cbaroot/certs/187227ec.0 files need to be landesk:landesk.
/opt/landesk/bin/broker_config # talks to the broker, requests a key/cert, doesn't "register" the server yet on the gui


# Running the ./NFI installer.sh program yeilds:
 /home/nfiiseed/ivanti/nixconfig.sh -d -a epmcore-02p.nfii.com -l /home/nfiiseed/ivanti/.stdout.log
and creates a log file in .stdout.log.

# steps

device id = $(facter dmi.product.uuid) | tr 'A-Z' 'a-z'  # /opt/landesk/etc/guid
mkdir /opt/landesk/etc
wget http://epmcore-02p.nfii.com/ldlogon/187227ec.0 to certs dir
wget tarballs for RPM installation
untar
verify rpm signatures 
create user landesk (rpm provides this...why is it creating user?)
Ensure sudo entry for landesk user:
        # landesk ALL=(ALL)  NOPASSWD: ALL
        # Defaults:landesk !requiretty

# installation order is important!
# update:  Installation order doesn't SEEM to be important in my testing - SchoneckerB
install ivanti-cba8
install ivanti-pds2
install ivanti-base-agent
wget -O /opt/landesk/var/cbaroot/certs/187227ec.0 -q http://epmcore-02p.nfii.com/ldlogon/187227ec.0
configure ./etc/landesk.conf: (change config files to allow privilegeEscalationAllowed)
# ensure -rw-r--r--. 1 landesk landesk 1517 Mar  7 09:58 landesk/etc/landesk.conf permissions.
  core
  device id (how is this determined?)
  agentversion
start cba8 service
sleep 5
install ivanti-inventory
install ivanti-schedule
install ivanti-software-distribution
install ivanti-vulnerability

"notify core install is complete"
# Doesn't look like this does anything other than send syslog message
# There is no communication to the core server when running this command.
/opt/landesk/bin/alert -f internal.cba8.install.complete

"verifying installation is running properly"



# modify conf files for permissions;  ensure landesk.conf is 644 landesk:landesk
sed -i 's/privilegeEscalationAllowed" : false/privilegeEscalationAllowed" : true/g' /opt/landesk/etc/{landesk,hardware,inventory,policy,software_distribution,vulnerability}.conf



# for i in broker_config ldiscan vulscan map-fetchpolicy; do echo $i;  /opt/landesk/bin/${i} ; echo press enter; read foo;done

run /opt/landesk/bin/broker_config (broker_config) # certificate pull?
run /opt/landesk/bin/ldiscan (ldiscan)


# at this point, the server should be visible in the epmcore console
# it may take 15-20s for it to appear.
run /opt/landesk/bin/vulscan (vulscan) # fetch policies?
run /opt/landesk/bin/map-fetchpolicy (map-fetchpolicy)

# Firewall ports
https://forums.ivanti.com/s/article/About-Ports-used-by-Ivanti-Endpoint-Manager-EPM-LANDESK-Management-Suite-LDMS-full-list?language=en_US

minimum on the agent are 9593, 9594, 9595.
  

# Here is a bash script that installs ivanti agent with the minimum amount of effort:
#!/bin/bash
yum -y install ivanti\*
wget -O /opt/landesk/var/cbaroot/certs/187227ec.0 -q http://epmcore-02p.nfii.com/ldlogon/187227ec.0
chown -R landesk:landesk /opt/landesk/
chmod o+r /opt/landesk/etc/landesk.conf
cat >> /opt/landesk/etc/landesk.conf <<EOF
Core=epmcore-02p.nfii.com
Device ID={$(dmidecode | grep UUID | awk -F: '{print $2}' | sed 's/ //g')}
AgentVersion=Ivanti 2021.1
EOF
sed -i 's/privilegeEscalationAllowed" : false/privilegeEscalationAllowed" : true/g' /opt/landesk/etc/{landesk,hardware,inventory,policy,software_distribution,vulnerability}.conf
systemctl start cba8
for i in broker_config ldiscan vulscan map-fetchpolicy; do echo $i;  /opt/landesk/bin/${i} -V; done

