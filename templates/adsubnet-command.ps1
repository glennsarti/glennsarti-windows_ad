$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

$SubnetName = '<%= @name %>'
$SubnetLocation = '<%= @location %>'
$SubnetSiteName = '<%= @site %>'
$EnsureType = '<%= @ensure %>'

Import-Module ActiveDirectory -Verbose:$false

$thisSubnet = $null
try {
  $thisSubnet = (Get-ADReplicationSubnet -Identity $SubnetName -ErrorAction 'Stop')
} catch { $thisSubnet = $null }

if ($EnsureType.ToUpper() -eq 'PRESENT') {
  $isFound = $false

  if ($thisSubnet -eq $null) {
    Write-Verbose "Creating the Subnet object called $SubnetName"
    $thisSubnet = New-ADReplicationSubnet -Name $SubnetName
  }

  if ($thisSubnet.Location -ne $SubnetLocation) {
    Write-Host "Setting subnet location to $SubnetLocation"
    Set-ADReplicationSubnet -Identity $SubnetName -Location $SubnetLocation
  }

  [string]$currentSite = $thisSubnet.Site
  if (-not ($currentSite.StartsWith("CN=$($SubnetSiteName),"))) {
    Write-Host "Setting subnet site allocation to $SubnetSiteName"
    $adSite = $null
    if ($SubnetSiteName -ne '') {
      $adSite = Get-ADReplicationSite -Identity $SubnetSiteName
      Set-ADReplicationSubnet -Identity $SubnetName -Site $adSite -Confirm:$false
    } else {
      Set-ADReplicationSubnet -Identity $SubnetName -Clear siteObject -Confirm:$false
    }
  }

  Exit 0
} else {
  Write-Verbose "Removing subnet $SubnetName"
  Remove-ADReplicationSubnet -Identity $SubnetName -Confirm:$false | Out-Null

  Exit 0
}


