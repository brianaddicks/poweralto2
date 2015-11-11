function Get-PaManagementAcl {
    [CmdletBinding()]
    Param (
    )

    $Xpath        = "/config/devices/entry/deviceconfig/system/permitted-ip"
    $RootNodeName = 'permitted-ip'

    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName } `
                                else { $ResponseData = $ResponseData               }

    $ResponseTable = @()
    foreach ($Entry in $ResponseData.Entry) {
        $ResponseTable += $Entry.Name
    }	

    return $ResponseTable
}