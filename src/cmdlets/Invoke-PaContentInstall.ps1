function Invoke-PaContentInstall {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False)]
        [switch]$Quiet,

        [Parameter(Mandatory=$False)]
        [switch]$ShowProgress,
        
        [Parameter(Mandatory=$False)]
        [switch]$WaitForCompletion,

        [Parameter(Mandatory=$True,ParameterSetName="av")]
        [switch]$Antivirus,

        [Parameter(Mandatory=$True,ParameterSetName="app")]
        [switch]$AppsAndThreats
    )

    if ($Antivirus) {
        $Command = "<request><anti-virus><upgrade><install><version>latest</version></install></upgrade></anti-virus></request>"
    }
    if ($AppsAndThreats) {
        $Command = "<request><content><upgrade><install><version>latest</version></install></upgrade></content></request>"
    }

    if ($ShowProgress) { $WaitForCompletion = $true }

    $ResponseData = Invoke-PaOperation $Command
    $global:test = $ResponseData
    $Job = $ResponseData.job

    $JobParams = @{ 'Id' = $Job
                    'CheckInterval' = 5 }

    if ($ShowProgress)      { $JobParams += @{ 'ShowProgress' = $true } }
    if ($WaitForCompletion) { $JobParams += @{ 'WaitForCompletion' = $true } }

    $JobStatus = Get-PaJob @JobParams
    if ($JobStatus.NextJob) {
        $JobParams.Set_Item('Id',$JobStatus.NextJob)
        $JobStatus = Get-PaJob @JobParams
    }
    $global:test2 = $JobStatus
    if ($JobStatus.Result -eq 'Fail') {
        Throw $JobStatus.Details
    }
}
