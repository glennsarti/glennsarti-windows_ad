define windows_ad::sitelink(
  $ensure = 'present',
  $sites = '',
  $cost = 100,
  $replication_interval = 180,
  $logoutput = false
) {

  validate_re($ensure, '^(present|absent)$', 'ensure must be one of \'present\' or \'absent\'')

  if $facts['msad_is_fsmo_pdc_role_owner'] == 'True' {
    exec { "ad_sitelink_$name":
      command   => template('windows_ad/adsitelink-command.ps1'),
      unless    => template('windows_ad/adsitelink-unless.ps1'),
      provider  => powershell,
      logoutput => $logoutput,
    }
  }
}
