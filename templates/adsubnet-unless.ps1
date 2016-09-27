$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

$SubnetName = '<%= @name %>'
$SubnetLocation = '<%= @location %>'
$SubnetSiteName = '<%= @site %>'
$EnsureType = '<%= @ensure %>'

#$SubnetName = '192.168.200.0/24'
#$SubnetLocation = 'US/OR/Portland'
#$SubnetSiteName = 'PDX'
#$EnsureType = 'present'

Import-Module ActiveDirectory -Verbose:$false

# Exit Code 1 means the command will be executed
$thisSubnet = $null
try {
  $thisSubnet = (Get-ADReplicationSubnet -Identity $SubnetName)
} catch { $thisSubnet = $null }

if ($EnsureType.ToUpper() -eq 'PRESENT') {
  $isFound = ($thisSubnet -ne $null)

  if ($thisSubnet -ne $null) {
    $isFound = ($isFound -and ($thisSubnet.Location -eq $SubnetLocation))
  }

  # Quick and dirty site object comparison.  This fail for x500 encoding of stuff
  # "CN=Default-First-Site-Name,CN=Sites
  if ($thisSubnet -ne $null) {
    [string]$currentSite = $thisSubnet.Site
    $isFound = ($isFound -and ($currentSite.StartsWith("CN=$($SubnetSiteName),")))
  }

  If ($isFound) { Exit 0 } else { Exit 1 }
} else {

  If ($thisSite -ne $null) { Exit 1 } else { Exit 0 }
}




