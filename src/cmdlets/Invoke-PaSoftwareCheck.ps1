function Invoke-PaSoftwareCheck {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False)]
        [switch]$Quiet
    )

    $ReturnObject = $False

    $Command = "<request><system><software><check></check></software></system></request>"

    $ResponseData = Invoke-PaOperation $Command
    $global:Test = $ResponseData
        

    $AvailableUpdates = $ResponseData.'sw-updates'.versions.entry
    if ($AvailableUpdates[0].Version -ne $Global:PaDeviceObject.OsVersion) {
        $ReturnObject = $true
    }

    return $ReturnObject
}
