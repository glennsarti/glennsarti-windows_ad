define windows_ad::dns::conditional_forwarder(
  $ensure = 'present',
  $dns_servers = '',
  $logoutput = true, #false
) {

  validate_re($ensure, '^(present|absent)$', 'ensure must be one of \'present\' or \'absent\'')
  validate_re($dns_servers, '^(.+)$', 'dns_servers must contain at least one entry')

  if $facts['msad_is_fsmo_pdc_role_owner'] == 'True' {
    #exec { "ad_sitelink_$name":
    #  command   => template('windows_ad/ad_dns_con_fwd-command.ps1'),
    #  unless    => template('windows_ad/ad_dns_con_fwd-unless.ps1'),
    #  provider  => powershell,
    #  logoutput => $logoutput,
    #}
  }
}
