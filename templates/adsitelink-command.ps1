$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

$SiteLinkName = '<%= @name %>'
$Sites = '<%= @sites %>'
$Cost = '<%= @cost %>'
$ReplicationInterval = '<%= @replication_interval %>'
$EnsureType = '<%= @ensure %>'

Import-Module ActiveDirectory -Verbose:$false

$thisSiteLink = $null
try {
  $thisSiteLink = (Get-ADReplicationSiteLink -Identity $SiteLinkName -ErrorAction 'Stop')
} catch { $thisSiteLink = $null }

if ($EnsureType.ToUpper() -eq 'PRESENT') {
  if ($thisSiteLink -eq $null) {
    Write-Verbose "Creating the SiteLink object called $SiteLinkName"
    $thisSiteLink = New-ADReplicationSiteLink -Name $SiteLinkName -SitesIncluded ($Sites -split ',')
  }

  Write-Host "Setting site cost to $Cost and replication interval to $ReplicationInterval"
  Set-ADReplicationSiteLink -Identity $SiteLinkName -Cost $Cost -ReplicationFrequencyInMinutes $ReplicationInterval -Confirm:$false

  # There are better ways to do this....
  Write-Host "Setting sites to $Sites"
  # Add required sites...
  $Sites -split ',' | % {
    Write-Verbose "Ensuring AD Site $_"
    Set-ADReplicationSiteLink -Identity $SiteLinkName -SitesIncluded @{'Add'=$_} -Confirm:$false
  }
  # Remove additional sites...
  $shouldSites = $Sites -split ','
  $thisSiteLink.SitesIncluded | % {
    $siteName =  (($_ -split ',')[0] -replace '^CN=','')
    if ($shouldSites -notcontains $siteName) {
      Write-Verbose "Removing AD Site $_"
      Set-ADReplicationSiteLink -Identity $SiteLinkName -SitesIncluded @{'Remove'=$_} -Confirm:$false
    }
  }

  Exit 0
} else {
  Write-Verbose "Removing Site Link $SiteLinkName"
  Remove-ADReplicationSiteLink -Identity $SiteLinkName -Confirm:$false | Out-Null

  Exit 0
}


