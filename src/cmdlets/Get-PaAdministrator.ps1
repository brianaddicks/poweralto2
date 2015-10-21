function Get-PaAdministrator {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name
    )

    $InfoObject   = New-Object PowerAlto.Administrator
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'users'

    if ($Name) { $Xpath += "/entry[@name='$Name']" }
    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName.entry } `
                                else { $ResponseData = $ResponseData.entry         }

    $ResponseTable = @()
    foreach ($r in $ResponseData) {
        $ResponseObject = New-Object PowerAlto.Administrator
        
        $ResponseObject.Name = $r.name
        $ResponseObject.AuthenticationProfile = $r.'authentication-profile'
        
        if ($r.permissions.'role-based'.custom) {
            $ResponseObject.AdminType = 'RoleBased'
            $ResponseObject.Role      = $r.permissions.'role-based'.custom.profile    
        } else {
            $ResponseObject.AdminType = 'Dynamic'
            $ResponseObject.Role      = ($r.permissions.'role-based' | gm -MemberType Property).Name
        }

        $ResponseTable += $ResponseObject
    }
    
    return $ResponseTable
}