define windows_ad::subnet(
  $ensure = 'present',
  $location = '',
  $site = '',
  $logoutput = false
) {

  validate_re($ensure, '^(present|absent)$', 'ensure must be one of \'present\' or \'absent\'')

  if $facts['msad_is_fsmo_pdc_role_owner'] == 'True' {
    #exec { "ad_subnet_$name":
    #  command   => template('windows_ad/adsubnet-command.ps1'),
    #  unless    => template('windows_ad/adsubnet-unless.ps1'),
    #  provider  => powershell,
    #  logoutput => $logoutput,
    #}
  }
}
