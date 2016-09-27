$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

$SiteName = '<%= @name %>'
$SiteDescription = '<%= @description %>'
$EnsureType = '<%= @ensure %>' 

Import-Module ActiveDirectory -Verbose:$false

$thisSite = $null
try {
  $thisSite = Get-ADReplicationSite -Identity $SiteName -ErrorAction 'Stop'
} catch {
  $thisSite = $null
}

if ($EnsureType.ToUpper() -eq 'PRESENT') {
  $isFound = $false

  if ($thisSite -eq $null) {
    Write-Verbose "Creating the Site object called $SiteName"
    $thisSite = New-ADReplicationSite -Name $SiteName
  }

  if ($thisSite.Description -ne $SiteDescription) {
    Write-Host "Setting site description to $SiteDescription"
    Set-ADReplicationSite -Identity $SiteName -Description $SiteDescription
  }

  Exit 0
} else {
  Write-Verbose "Removing site $SiteName"
  Remove-ADReplicationSite -Identity $SiteName -Confirm:$false | Out-Null

  Exit 0
}


