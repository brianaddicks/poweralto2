function Get-PaSystemLogSettings {
    [CmdletBinding()]
    Param (
    )

    $Xpath        = "/config/shared/log-settings/system"
    $RootNodeName = 'system'

    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName } `
                                else { $ResponseData = $ResponseData               }

    $ResponseTable = @()
	
	
    $Severities = @("informational"
                    "low"
                    "medium"
                    "high"
                    "critical")
    
    foreach ($Severity in $Severities) {
        $ResponseObject                    = New-Object PowerAlto.SystemLogSetting
        $ResponseObject.Severity           = $Severity
        $ResponseObject.Syslog   = $ResponseData.$Severity.'send-syslog'.'using-syslog-setting'
        $ResponseObject.SnmpTrap = $ResponseData.$Severity.'send-snmptrap'.'using-snmptrap-setting'
        $ResponseObject.Email    = $ResponseData.$Severity.'send-email'.'using-email-setting'
        if ($ResponseData.'send-to-panorama' -eq "yes") { $ResponseObject.$Severity.Panorama = $true }
        
        $ResponseTable += $ResponseObject
    }
    
    
    return $ResponseTable
}