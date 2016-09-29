$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

$SiteLinkName = '<%= @name %>'
$Sites = '<%= @sites %>'
$Cost = '<%= @cost %>'
$ReplicationInterval = '<%= @replication_interval %>'
$EnsureType = '<%= @ensure %>'

Import-Module ActiveDirectory -Verbose:$false

# Exit Code 1 means the command will be executed
$thisSiteLink = $null
try {
  $thisSiteLink = (Get-ADReplicationSiteLink -Identity $SiteLinkName -ErrorAction 'Stop')
} catch { $thisSiteLink = $null }

if ($EnsureType.ToUpper() -eq 'PRESENT') {
  $isFound = ($thisSiteLink -ne $null)

  if ($thisSiteLink -ne $null) {
    $isFound = ($isFound -and ($thisSiteLink.Cost -eq $Cost))
  }

  if ($thisSiteLink -ne $null) {
    $isFound = ($isFound -and ($thisSiteLink.ReplicationFrequencyInMinutes -eq $ReplicationInterval))
  }

  if ($thisSiteLink -ne $null) {
    $shouldSites = $Sites -split ','
    $currentCount = 0
    $thisSiteLink.SitesIncluded | % {
      $siteName =  (($_ -split ',')[0] -replace '^CN=','')
      if ($shouldSites -contains $siteName) { $currentCount++ }
    }
    $isFound = ($isFound -and ($currentCount -eq $shouldSites.Count))
  }

  If ($isFound) { Exit 0 } else { Exit 1 }
} else {
  If ($thisSiteLink -ne $null) { Exit 1 } else { Exit 0 }
}




