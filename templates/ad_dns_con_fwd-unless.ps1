$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

$FwdDomainName = '<%= @name %>'
$FwdDNSServers = '<%= @dns_servers %>'
$EnsureType = '<%= @ensure %>'

# Exit Code 1 means the command will be executed

$thisForwarder = Get-WMIObject -Namespace root\MicrosoftDNS -Class MicrosoftDNS_Zone -Filter "ZoneType = 4" | ? { $_.ContainerName -eq $FwdDomainName }

if ($EnsureType.ToUpper() -eq 'PRESENT') {
  $isFound = ($thisForwarder -ne $null)

  # This is a little broken as order matters.
  if ($thisForwarder -ne $null) {
    $shouldDNSServers = $FwdDNSServers -split ','
    $currentCount = 0
    $thisForwarder.MasterServers | % {
      if ($shouldDNSServers -contains $_) { $currentCount++ }
    }
    $isFound = ($isFound -and ($currentCount -eq $shouldDNSServers.Count))
  }

  If ($isFound) { Exit 0 } else { Exit 1 }
} else {

  If ($thisForwarder -ne $null) { Exit 1 } else { Exit 0 }
}

