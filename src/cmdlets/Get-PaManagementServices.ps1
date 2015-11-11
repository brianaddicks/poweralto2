function Get-PaManagementServices {
    [CmdletBinding()]
    Param (
    )

    $InfoObject   = New-Object PowerAlto.ManagementServices
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'service'

    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName } `
                                else { $ResponseData = $ResponseData               }

	$ResponseObject = New-Object PowerAlto.ManagementServices
	
    if ($ResponseData.'disable-telnet' -eq "yes") { $ResponseObject.DisableTelnet = $true  } `
                                             else { $ResponseObject.DisableTelnet = $false }
    
    if ($ResponseData.'disable-http' -eq "yes") { $ResponseObject.DisableHttp = $true  } `
                                           else { $ResponseObject.DisableHttp = $false }
                                             
    if ($ResponseData.'disable-userid-service' -eq "no") { $ResponseObject.DisableUserId = $false  } `
                                                    else { $ResponseObject.DisableUserId = $true  }
    
    if ($ResponseData.'disable-snmp' -eq "no") { $ResponseObject.DisableSnmp = $false  } `
                                          else { $ResponseObject.DisableSnmp = $true }
    return $ResponseObject
}