function Invoke-PaContentCheck {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False)]
        [switch]$Quiet,

        [Parameter(Mandatory=$False)]
        [switch]$Antivirus,

        [Parameter(Mandatory=$False)]
        [switch]$AppsAndThreats,

        [Parameter(Mandatory=$False)]
        [switch]$All = $true
    )

    if ($Antivirus -or $AppsAndThreats) {
        $All = $False
    }
    $ReturnObject = $False

    if ($AppsAndThreats -or $All) {
        $Command = "<request><content><upgrade><check></check></upgrade></content></request>"

        $ResponseData = Invoke-PaOperation $Command

        

        $AvailableUpdates = $ResponseData.'content-updates'.entry
        if ($AvailableUpdates.current -eq 'no') {
            if ($Quiet) {
                $ReturnObject = $true
            } else {
                $ReturnObject = @($AvailableUpdates)
            }
        }
    }

    if ($Antivirus -or $All) {
        $Command = "<request><anti-virus><upgrade><check></check></upgrade></anti-virus></request>"

        $ResponseData = Invoke-PaOperation $Command

        $AvailableUpdates = $ResponseData.'content-updates'.entry
        if ($AvailableUpdates.current -eq 'no') {
            if ($Quiet) {
                $ReturnObject = $true
            } else {
                if ($ReturnObject.Gettype().BaseType.Name -eq "array") {
                    $ReturnObject += @($AvailableUpdates)
                } else {
                    $ReturnObject = @($AvailableUpdates)
                }
            }
        }
    }

    return $ReturnObject
}
