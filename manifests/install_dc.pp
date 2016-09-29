define windows_ad::install_dc(
  $domain_name = '',
  $domain_admin_username,
  $domain_admin_password,
  $safemode_admin_username,
  $safemode_admin_password,
  $is_first_dc = true,
  $first_dc_dns = '',
) {
  validate_re($domain_name, '\.', "domain_name of '$domain_name' cannot be a top level domain or empty")
  
  # Install a DC is guarded so it doesn't accidentally try to move a
  # DC to a different domain. Bad stuff happens then
  if $facts['msad_is_domain_controller'] == 'False' {
    reboot { 'ad_dc_dc_install_reboot' :
      message => 'AD DC installation has requested a reboot',
      apply => 'immediately',
    }

    dsc_windowsfeature { 'rsat-adds':
      ensure => present,
      dsc_name => 'rsat-adds',
    }

    dsc_windowsfeature { 'ad-domain-services':
      ensure => present,
      dsc_name => 'ad-domain-services',
    }
    
    # First DC in a domain
    if $is_first_dc {
      dsc_xaddomain { 'ad_dc_domain':
        ensure => present,
        dsc_domainname => $domain_name,
        dsc_domainadministratorcredential =>  { user => $domain_admin_username, password => $domain_admin_password },
        dsc_safemodeadministratorpassword => { user => $safemode_admin_username, password => $safemode_admin_password },
        require => Dsc_windowsfeature['ad-domain-services'],
        notify => Reboot['ad_dc_dc_install_reboot'],
      }
    } else {
      # Set the DNS the first DSC server
      dsc_xdnsserveraddress { 'PriDNSServer':
        ensure => present,
        dsc_address        => $first_dc_dns,
        dsc_interfacealias => $facts['networking']['primary'],
        dsc_addressfamily  => "IPv4",
      }
      # Additional DC in a domain
      dsc_xaddomaincontroller { 'ad_dc_domain_controller':
        ensure => present,
        dsc_domainname => $domain_name,
        dsc_domainadministratorcredential =>  { user => $domain_admin_username, password => $domain_admin_password },
        dsc_safemodeadministratorpassword => { user => $safemode_admin_username, password => $safemode_admin_password },
        require => Dsc_windowsfeature['ad-domain-services'],
        notify => Reboot['ad_dc_dc_install_reboot'],
      }
    }
  } else {
    # Check that it's the right domain
    if $facts['msad_domain_name'] != $domain_name {
      fail("AD Domain name was expected to be '${$domain_name}' but found '${$facts['msad_domain_name']}'")
    }

    # Set the DNS the local server
    dsc_xdnsserveraddress { 'PriDNSServer':
      ensure => present,
      dsc_address        => $facts['networking']['ip'],
      dsc_interfacealias => $facts['networking']['primary'],
      dsc_addressfamily  => "IPv4",
    }
  }

# TODO Export a resource with the domain information so that other resources can figure out how to join the domain correctly.
}
