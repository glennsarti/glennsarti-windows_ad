$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

$TrusteeDomain = '<%= @name %>'
$TrustDirection = '<%= @direction %>'
$EnsureType = '<%= @ensure %>'

Import-Module ActiveDirectory -Verbose:$false

# Exit Code 1 means the command will be executed
$thisTrust = $null
try {
  # There may be more properties to check than just these two
  $thisTrust = Get-ADTrust -Filter {Target -eq $TrusteeDomain} | ? { $_.Direction.ToString().ToUpper() -eq $TrustDirection.ToUpper() } 
} catch { $thisTrust = $null }

if ($EnsureType.ToUpper() -eq 'PRESENT') {
  If ($thisTrust -ne $null) { Exit 0 } else { Exit 1 }
} else {
  If ($thisTrust -ne $null) { Exit 1 } else { Exit 0 }
}


