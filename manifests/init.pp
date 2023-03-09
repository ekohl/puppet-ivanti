# @summary A short summary of the purpose of this class
#
# A description of what this class does

# @packages
# The packages required to install Ivanti
#
# @example
#   include ivanti
class ivanti (
  String $core_certificate,
  Stdlib::Fqdn           $core_fqdn,
  String $device_id = $facts['dmi']['product']['uuid'].downcase(),
  Stdlib::Httpurl   $external_url                    = "http://${core_fqdn}/ldlogon/${core_certificate}",
  Stdlib::Httpurl $linux_baseclients = "http://${core_fqdn}/ldlogon/unix/linux/baseclient64.tar.gz",  # Linux base client location for non-yum install
  Optional[Variant[Array, String]] $packages = $ivanti::packages,
  Optional[Boolean] $cba = true, # Standard LANDesk Agents
  Optional[Boolean] $sd  = true, # Software Distribution
  Optional[Boolean] $vd  = true, # Vulnerability Scanner
  Optional[Variant[Array, Integer]] $firewall_ports = [9593, 9594, 9595],
  Optional[Boolean] $privilegeescalationallowed = true,
  Optional[Hash] $config_files = $ivanti::config_files,
  Stdlib::Unixpath $install_dir     = '/opt/landesk',
) {
  # Install the Ivanti packages
  package { $packages:
    ensure => installed,
  }

#  # Configure sudoers for landesk user AND allow tty-less sudo.
#  file { '/etc/sudoers.d/10_landesk':
#    content => "Defaults:landesk !requiretty \nlandesk ALL=(ALL) NOPASSWD: ALL",
#    owner   => root,
#    group   => root,
#    mode    => '0600',
#  }

  # Install the SSL certificate from the core server.
  file { "${install_dir}/var/cbaroot/certs/${core_certificate}":
    owner   => 'landesk',
    group   => 'landesk',
    mode    => '0644',
    source  => $external_url,
    require => Package[$packages],
  }

  # 0644 is not the default mode for the conf files; 0640 is the default mode.  Unfortunately, the
  # cba8 daemon doesn't run properly unless ./etc/landesk.conf has the other read bit set (o+r) so
  # we have to accommodate that fact by merging in default settings into the $config_files (below).
  # The following files have ./bin and ./etc
  $config_file_defaults = {
    owner   => 'landesk',
    group   => 'landesk',
    mode    => '0640',
    before  => Service['cba8'], # Ensure these files are managed before starting/restarting
    notify  => Service['cba8'],
  }

  # Manage files in /opt/landesk/etc/.  Changes to any conf file will trigger the cba8 service restart
  # and a cascade of exec resources.
  $config_files.each | $config_file, $config_file_attributes | {
    # Merge any settings from the hiera hash to create a default set of parameters.
    $attributes = deep_merge($config_file_defaults, $config_file_attributes)
    file { "${config_file}.conf":
      *       => $attributes,
      path    => "${install_dir}/etc/${config_file}.conf",
      content => template("ivanti/${config_file}.conf.erb"),
    }
  }

  service { 'cba8':
    ensure  => 'running',
    enable  => true,
    require => Package[$packages],
    notify  => Exec['broker_config'],
  }

  # TODO firewall rules OR a firewall XML file.

  # Execute the commands to register and then scan the agent.
  # The schedule exec is removed in the short term because the binary fails to return a zero return code.
  # $execs = ['agent_settings', 'broker_config', 'inventory', 'ldiscan', 'policy', 'schedule', 'software_distribution', 'vulnerability',]
  # Since all of the execs are run in order, we only need to require Service[cba8] on the first exec in the list (agent_settings).
  exec { 'agent_settings':
    command     => "${install_dir}/bin/agent_settings -V",
    user        => 'root',
    logoutput   => true,
    refreshonly => true,
    require     => Service['cba8'],
    notify      => Exec['broker_config'],
  }
  exec { 'broker_config':
    command     => "${install_dir}/bin/broker_config -V",
    user        => 'root',
    logoutput   => true,
    refreshonly => true,
    notify      => Exec['ldiscan'],
  }
  exec { 'ldiscan':
    command     => "${install_dir}/bin/ldiscan -V",
    user        => 'root',
    logoutput   => true,
    refreshonly => true,
    notify      => Exec['vulscan'],
  }
  exec { 'vulscan':
    command     => "${install_dir}/bin/vulscan -V",
    user        => 'root',
    logoutput   => true,
    refreshonly => true,
    notify      => Exec['map-fetchpolicy'],
  }
  exec { 'map-fetchpolicy':
    command     => "${install_dir}/bin/map-fetchpolicy -V",
    user        => 'root',
    logoutput   => true,
    refreshonly => true,
  }

  # Ordering of a few execs is important
  # The ordering here was taken from the .sdtout.log file that is created when installing Ivanti
  # from the bash script.  I'm not sure if the ordering really matters but it makes sense that the broker_config
  # needs to run before ldiscan.  All other ordering is semi-arbitrary (ie, I made a best guess).
  Exec['agent_settings'] ~> Exec['broker_config'] ~> Exec['ldiscan'] ~> Exec['vulscan'] ~> Exec['map-fetchpolicy']
}
