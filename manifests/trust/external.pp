define windows_ad::trust::external(
  $ensure = 'present',
  $direction = 'outbound',
  $initial_trust_password = 'trustpwd',
  $logoutput = false,
) {

  # All trusts are one-way.
  # one-way inbound, i.e. domain $name trusts me
  # one-way outbound, i.e. I trust the domain $name

  # Only uses Domain-Wide Auth

  validate_re($ensure, '^(present|absent)$', 'ensure must be one of \'present\' or \'absent\'')
  validate_re($direction, '^(inbound|outbound)$', 'ensure must be one of \'inbound\' or \'outbound\'')

  if $facts['msad_is_fsmo_pdc_role_owner'] == 'True' {
    exec { "ad_site_$name":
      command   => template('windows_ad/adtrustexternal-command.ps1'),
      unless    => template('windows_ad/adtrustexternal-unless.ps1'),
      provider  => powershell,
      logoutput => $logoutput,
    }
  }
}
