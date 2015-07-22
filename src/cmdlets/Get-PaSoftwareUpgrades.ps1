function Get-PaSoftwareUpgrades {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False)]
        [switch]$Quiet,

        [Parameter(Mandatory=$False)]
        [switch]$ShowProgress,
        
        [Parameter(Mandatory=$False)]
        [switch]$WaitForCompletion,

        [Parameter(Mandatory=$True,ParameterSetName="latest")]
        [switch]$Latest,

        [Parameter(Mandatory=$True,ParameterSetName="nextstep")]
        [switch]$NextStep,

        [Parameter(Mandatory=$True,ParameterSetName="version")]
        [string]$Version
    )
    
    $CmdletName = $MyInvocation.MyCommand.Name

    $AvailableSoftware = Get-PaSoftwareInfo
    $CurrentVersion    = $Global:PaDeviceObject.OsVersion

    if ($Latest)  { $DesiredEntry = $AvailableSoftware[0] }
    if ($Version) { $DesiredEntry = $AvailableSoftware | ? { $_.Version -eq $Version } }
    
    if ($NextStep) {
        $MajorReleases       = $AvailableSoftware | Select @{Name = 'MajorRelease'; Expression = {$_.Version.SubString(0,3)}} -Unique
        $CurrentMajorRelease = $CurrentVersion.Substring(0,3)
        $CurrentIndex        = [array]::IndexOf($MajorReleases.MajorRelease,$CurrentMajorRelease)
        HelperWriteCustomVerbose $CmdletName "CurrentIndex: $CurrentIndex"
        if ($CurrentIndex -gt 0) {
            $DesiredIndex        = $CurrentIndex - 1
        } else {
            $DesiredIndex = $CurrentIndex
        }
        $DesiredMajorRlease  = [string]($MajorReleases[$DesiredIndex].MajorRelease)
        $DesiredVersion      = $DesiredMajorRlease + '.0'
        
        if ($CurrentMajorRelease -eq $DesiredMajorRlease) {
            HelperWriteCustomVerbose $CmdletName "CurrentMajorRelease ($CurrentVersion) matches DesiredMajorRelase ($DesiredMajorRlease)"
            $DesiredEntry = $AvailableSoftware[0]
        } else {
            $DesiredEntry = $AvailableSoftware | ? { $_.Version -eq $DesiredVersion }
        }
    }

    Write-Debug "CurrentVersion is $CurrentVersion, Downloading $($DesiredEntry.Version)"

    
    if ($DesiredEntry.Downloaded -eq 'no') {
        $Command = "<request><system><software><download><version>$($DesiredEntry.Version)</version></download></software></system></request>"

        $ResponseData = Invoke-PaOperation $Command
        $global:test  = $ResponseData
        $Job          = $ResponseData.job
    
        $JobParams = @{ 'Id' = $Job
                        'CheckInterval' = 5 }
    
        if ($ShowProgress)      {
            $JobParams += @{ 'ShowProgress' = $true } 
            $WaitForCompletion = $true
        }

        if ($WaitForCompletion) { $JobParams += @{ 'WaitForCompletion' = $true } }

        $JobStatus = Get-PaJob @JobParams
        if ($JobStatus.Result -eq 'Fail') {
            Throw $JobStatus.Details
        }
        return $JobStatus
    } else {
        return $DesiredEntry.Version + " already downloaded"
    }
    
}
