$ErrorActionPrefence = 'Stop'
$factPrefix = "msad_"

# Get basic information
$isDC = "False"
$thisDomainName = ''
$thisComputer = Get-WMIObject Win32_ComputerSystem
switch (($thisComputer).domainrole) {
  1 { $thisDomainName = $thisComputer.Domain } # Member Workstation
  3 { $thisDomainName = $thisComputer.Domain } # Member Server
  4 { $isDC = "True" } # Legacy BDC
  5 { $isDC = "True" } # Legacy PDC
}

Write-Output "$($factPrefix)is_domain_controller=$isDC"

if ($isDC -eq 'True') {
  Import-Module ActiveDirectory -ErrorAction 'SilentlyContinue' 
  
  $thisDC = Get-ADDomainController -ErrorAction 'SilentlyContinue'
  if ($thisDC -ne $null) {
    $thisDCName = $thisDC.Hostname.ToLower()

    Write-Output "$($factPrefix)site_name=$($thisDC.Site)"
    
    Write-Output "$($factPrefix)is_rodc=$($thisDC.IsReadOnly)"
    Write-Output "$($factPrefix)is_global_catalog=$($thisDC.IsGlobalCatalog)"
    
    # Get the Forest functional level            
    $thisForest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
    Write-Output "$($factPrefix)forest_name=$($thisForest.Name)"
    Write-Output "$($factPrefix)forest_functional_level=$($thisForest.ForestMode.ToString().ToLower())"

    Write-Output "$($factPrefix)is_fsmo_schema_role_owner=$($thisForest.SchemaRoleOwner.ToString().ToLower() -eq $thisDCName)"
    Write-Output "$($factPrefix)is_fsmo_naming_role_owner=$($thisForest.NamingRoleOwner.ToString().ToLower() -eq $thisDCName)"
    
    # Get the Forest functional level            
    $thisDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
    $thisDomainName = $thisDomain.name
    Write-Output "$($factPrefix)domain_functional_level=$($thisDomain.DomainMode.ToString().ToLower())"

    Write-Output "$($factPrefix)is_fsmo_pdc_role_owner=$($thisDomain.PdcRoleOwner.ToString().ToLower() -eq $thisDCName)"
    Write-Output "$($factPrefix)is_fsmo_rid_role_owner=$($thisDomain.RIDRoleOwner.ToString().ToLower() -eq $thisDCName)"
    Write-Output "$($factPrefix)is_fsmo_infrastructure_role_owner=$($thisDomain.InfrastructureRoleOwner.ToString().ToLower() -eq $thisDCName)"
  }
}
if ($thisDomain -ne '') { Write-Output "$($factPrefix)domain_name=$($thisDomain)" }
