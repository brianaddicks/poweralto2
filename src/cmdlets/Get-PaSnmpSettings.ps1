function Get-PaSnmpSettings {
    [CmdletBinding()]
    Param (
    )

    $InfoObject   = New-Object PowerAlto.SnmpSettings
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'snmp-setting'

    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName } `
                                else { $ResponseData = $ResponseData               }

	$ResponseObject = New-Object PowerAlto.SnmpSettings
	
	$ResponseObject.Location = $ResponseData.'snmp-system'.location
    $ResponseObject.Contact = $ResponseData.'snmp-system'.contact
    if ($ResponseData.'access-setting'.version.v2c) {
        $ResponseObject.Version = "v2c"
        $ResponseObject.Community = $ResponseData.'access-setting'.version.v2c.'snmp-community-string'
    } else {
        $ResponseObject.Version = "v3"
        Write-Warning "v3 not supported yet"
    }
	
    return $ResponseObject
}