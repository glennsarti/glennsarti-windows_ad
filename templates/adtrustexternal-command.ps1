$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

$TrusteeDomain = '<%= @name %>'
$TrustDirection = '<%= @direction %>'
$TrustPassword = '<%= @initial_trust_password %>'
$EnsureType = '<%= @ensure %>'

Import-Module ActiveDirectory -Verbose:$false

# Exit Code 1 means the command will be executed
$thisTrust = $null
try {
  # There may be more properties to check that just these two
  $thisTrust = Get-ADTrust -Filter {Target -eq $TrusteeDomain} | ? { $_.Direction.ToString().ToUpper() -eq $TrustDirection.ToUpper() } 
} catch { $thisTrust = $null }

Write-Verbose "Getting the current domain information..."
$thisDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()

if ($EnsureType.ToUpper() -eq 'PRESENT') {

  Write-Verbose "Creating the local side of the trust..."
  $thisDomain.CreateLocalSideOfTrustRelationship($TrusteeDomain,$TrustDirection,$TrustPassword)

  if ($TrustDirection.ToUpper() -eq 'outbound') {
    Write-Verbose "Verifying the outbound trust (Errors may indicate that the other end of the trust has not been created) ..."
    try {
      $thisDomain.VerifyOutboundTrustRelationship($TrusteeDomain)
    } catch {
      Write-Warning "$_ occured while verifying the trust"
    }
  }

  Exit 0
} else {
  Write-Verbose "Removing $TrustDirection trust to $TrusteeDomain ..."

  $thisDomain.DeleteLocalSideOfTrustRelationship($TrusteeDomain)

  Exit 0
}



