function Get-PaAdminIdleTimeout {
    [CmdletBinding()]
    Param (
    )

    $Xpath        = "/config/devices/entry/deviceconfig/setting/management/idle-timeout"
    $RootNodeName = 'permitted-ip'

    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    try {
        $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action
    } catch {
        if ($_ -match "No such node.") {
            return "60 minutes"
        } else {
            Throw $_
        }
    }

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName } `
                                else { $ResponseData = $ResponseData               }

    $ResponseTable = $ResponseData."idle-timeout"

    return $ResponseTable + " minutes"
}