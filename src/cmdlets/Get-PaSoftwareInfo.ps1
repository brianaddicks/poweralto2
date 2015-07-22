function Get-PaSoftwareInfo {
    [CmdletBinding()]

    $ReturnObject = $False

    $Command = "<request><system><software><info></info></software></system></request>"

    $ResponseData = Invoke-PaOperation $Command
    $global:Test  = $ResponseData
    
    return $ResponseData.'sw-updates'.versions.entry
}
