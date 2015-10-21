function Get-PaAuthenticationProfile {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name
    )

    $InfoObject   = New-Object PowerAlto.AuthenticationProfile
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'authentication-profile'

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
        $ResponseObject = New-Object PowerAlto.AuthenticationProfile
        
        $ResponseObject.Name           = $r.name
        $ResponseObject.LockoutTime    = $r.lockout.'lockout-time'
        $ResponseObject.FailedAttempts = $r.lockout.'failed-attempts'
        $ResponseObject.Method         = ($r.method | gm -MemberType Property).Name
        $ResponseObject.ServerProfile  = $r.method."$($ResponseObject.Method)".'server-profile'
        $ResponseObject.AllowList      = $r.'allow-list'.member

        $ResponseTable += $ResponseObject
    }
    
    return $ResponseTable
}