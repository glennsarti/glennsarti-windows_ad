$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

$SiteName = '<%= @name %>'
$SiteDescription = '<%= @description %>'
$EnsureType = '<%= @ensure %>'

Import-Module ActiveDirectory -Verbose:$false

# Exit Code 1 means the command will be executed

$thisSite = $null
try {
  $thisSite = Get-ADReplicationSite -Identity $SiteName -ErrorAction 'Stop'
} catch {
  $thisSite = $null
}

if ($EnsureType.ToUpper() -eq 'PRESENT') {
  $isFound = $false

  if ($thisSite -ne $null) {
    $isFound = ($thisSite.Description -eq $SiteDescription)
  }

  If ($isFound) { Exit 0 } else { Exit 1 }
} else {
  If ($thisSite -ne $null) { Exit 1 } else { Exit 0 }
}
