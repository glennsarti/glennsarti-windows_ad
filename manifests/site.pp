define windows_ad::site(
  $ensure = 'present',
  $description = '',
  $logoutput = false,
) {

  validate_re($ensure, '^(present|absent)$', 'ensure must be one of \'present\' or \'absent\'')

  if $facts['msad_is_fsmo_pdc_role_owner'] == 'True' {
    #exec { "ad_site_$name":
    #  command   => template('windows_ad/adsite-command.ps1'),
    #  unless    => template('windows_ad/adsite-unless.ps1'),
    #  provider  => powershell,
    #  logoutput => $logoutput,
    #}
  }
}
