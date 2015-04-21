function Get-PaJob {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False,Position=0)]
        [int]$Id,

        [Parameter(Mandatory=$False)]
        [switch]$ShowProgress,

        [Parameter(Mandatory=$False)]
        [switch]$WaitForCompletion
    )

    if ($Id) {
        $Command = "<show><jobs><id>$Id</id></jobs></show>"
    } else {
        $Command = "<show><jobs><all></all></jobs></show>"
    }

    if ($ShowProgress) { $WaitForCompletion = $true }

    $ResponseData = Invoke-PaOperation $Command
    $Global:test = $ResponseData

    function ProcessEntry ($Entry) {
        $NewJob = New-Object PowerAlto.Job
        $NewJob.Id = $Entry.id
        $NewJob.TimeEnqueued = $Entry.tenq
        $NewJob.User = $Entry.user
        $NewJob.Type = $Entry.type
        $NewJob.Status = $Entry.status
        $NewJob.Result = $Entry.result
        $NewJob.TimeCompleted = $Entry.tfin
        $NewJob.Details = $Entry.details.line
        $NewJob.Warnings = $Entry.warnings.line

        if ($Entry.stoppable -eq 'yes') {
            $NewJob.Stoppable = $true
        } else {
            $NewJob.Stoppable = $False
        }

        if ($Entry.progress -match '^\d+$') {
            $NewJob.Progress = $Entry.progress
        } elseif ($Entry.Status -eq 'FIN') {
            $NewJob.Progress = 100
        }

        return $NewJob
    }

    $ReturnObjects = @()

    if ($WaitForCompletion) {
        $ActiveJob = ProcessEntry $ResponseData.job
        if ($ShowProgress) {
            $ProgressParams = @{'Activity'         = $ActiveJob.Type
                                'CurrentOperation' = 'Checking status in 15 seconds...'
                                'Status'           = "$($ActiveJob.Progress)% complete"
                                'Id'               = $ActiveJob.Id
                                'PercentComplete'  = $ActiveJob.Progress}
            Write-Progress @ProgressParams
        }

        while ($ActiveJob.Progress -ne 100) {
            #Start-Sleep -s 15
            

            $i = 0
            while ($i -lt 15) {
                Start-Sleep -s 1
                $i ++
                if ($ShowProgress) {
                    $ProgressParams.Set_Item("CurrentOperation","Checking Status in $(15 - $i) seconds...")
                    Write-Progress @ProgressParams
                }
            }
            
            if ($ShowProgress) {
                $ProgressParams.Set_Item("CurrentOperation","Checking Status now")
                Write-Progress @ProgressParams
            }
             
            $UpdateJob = Invoke-PaOperation $Command
            $ActiveJob = ProcessEntry $UpdateJob.Job

            if ($ShowProgress) {
                $ProgressParams.Set_Item("PercentComplete",$ActiveJob.Progress)
                $ProgressParams.Set_Item('Status',"$($ActiveJob.Progress)% complete")
                Write-Progress @ProgressParams
            }
        }
        $ReturnObjects += $ActiveJob
    } else {
        foreach ($j in $ResponseData.job) {
            $ReturnObjects += ProcessEntry $j
        }
    }

    return $ReturnObjects
}
