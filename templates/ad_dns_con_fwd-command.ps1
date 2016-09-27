$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

$FwdDomainName = '<%= @name %>'
$FwdDNSServers = '<%= @dns_servers %>'
$EnsureType = '<%= @ensure %>'

# Exit Code 1 means the command will be executed

$thisForwarder = Get-WMIObject -Namespace root\MicrosoftDNS -Class MicrosoftDNS_Zone -Filter "ZoneType = 4" | ? { $_.ContainerName -eq $FwdDomainName }

if ($EnsureType.ToUpper() -eq 'PRESENT') {
  $isFound = $false

  if ($thisForwarder -eq $null) {
    Write-Verbose "Creating the DNS Forwarder for $FwdDomainName"

    Add-DnsServerConditionalForwarderZone -Name $FwdDomainName -ReplicationScope "Domain" -MasterServers ($FwdDNSServers -split ',')

    $thisForwarder = Get-WMIObject -Namespace root\MicrosoftDNS -Class MicrosoftDNS_Zone -Filter "ZoneType = 4" | ? { $_.ContainerName -eq $FwdDomainName }
  }

  # Set the Master Server List
  Write-Verbose "Setting Master Server list..."
  Set-DnsServerConditionalForwarderZone -Name $FwdDomainName -MasterServers ($FwdDNSServers -split ',') | Out-Null

  Exit 0
} else {
  Write-Verbose "Removing forwarder for $FwdDomainName"
  & dnscmd /zonedelete $FwdDomainName /DsDel /f

  Exit 0
}


