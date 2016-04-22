function Get-PaLog {
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$True,Position=0,ParameterSetName="newlog")]
		[string]$LogType,
        
        [Parameter(Mandatory=$False,ParameterSetName="newlog")]
		[string]$Query,
        
        [Parameter(Mandatory=$False,ParameterSetName="newlog")]
        [ValidateRange(20,5000)]
		[int]$NumberOfLogs = 20,
        
        [Parameter(Mandatory=$True,Position=0,ParameterSetName="getlog")]
		[string]$Action,
        
        [Parameter(Mandatory=$True,Position=1,ParameterSetName="getlog")]
		[int]$Job,
        
        [Parameter(Mandatory=$False)]
        [switch]$WaitForJob
    )

    HelperCheckPaConnection

    $QueryTable = @{ "type" = "log" }
    
    if ($LogType) {
        $QueryTable."log-type" = $LogType
        $QueryTable.query      = $Query
        $QueryTable.nlogs      = $NumberOfLogs
    } else {
        $QueryTable.action   = $Action
        $QueryTable."job-id" = $Job
    }
    
    $QueryString = HelperCreateQueryString $QueryTable
    $Url         = $global:PaDeviceObject.UrlBuilder($QueryString)
    $Response    = $global:PaDeviceObject.HttpQuery($url)
    $Response    = HelperCheckPaError $Response
    if ($WaitForJob) {
        if (!($Response.job)) { return $Repsonse } 
        
        $QueryTable = @{ "type" = "log" }
        $QueryTable.action   = "get"
        $QueryTable."job-id" = $Response.job
        
        $QueryString = HelperCreateQueryString $QueryTable
        $Url         = $global:PaDeviceObject.UrlBuilder($QueryString)
        $Response    = $global:PaDeviceObject.HttpQuery($url)
        $Response    = HelperCheckPaError $Response
        
        while($Response.job.status -ne "FIN") {
            Write-Verbose "Sleeping 5 Seconds"
            Write-Verbose $url
            Write-Verbose $Response.job.status
            sleep 5000
            $Response    = $global:PaDeviceObject.HttpQuery($url)
            $Response    = HelperCheckPaError $Response
        }
    }

    return $Response
}