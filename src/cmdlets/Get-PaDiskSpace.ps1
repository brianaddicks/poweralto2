function Get-PaDiskSpace {
    [CmdletBinding()]
    Param (
    )

    $Command = "<show><system><disk-space></disk-space></system></show>"

    $ResponseData = Invoke-PaOperation $Command
    $Global:test = $ResponseData

    $ResponseSplit = $ResponseData.'#cdata-section'.Split("`r`n")
    
    $OutputRx = [regex] '(?msx)
                         (?<filesystem>[a-z0-9\/]+)\ +
                         (?<size>[0-9\.A-Z]+)\ +
                         (?<used>[0-9\.A-Z]+)\ +
                         (?<available>[0-9\.A-Z]+)\ +
                         (?<percent>\d+%)\ +
                         (?<mount>[\/a-z]+)
                         '
    $ReturnObjects = @()

    foreach ($r in $ResponseSplit) {
        $Match = $OutputRx.Match($r)
        if ($Match.Success) {
            $ReturnObject             = "" | Select FileSystem,Size,Used,Available,PercentUsed,MountPoint
            $ReturnObject.FileSystem  = $Match.Groups['filesystem'].Value
            $ReturnObject.Size        = $Match.Groups['size'].Value
            $ReturnObject.Used        = $Match.Groups['used'].Value
            $ReturnObject.Available   = $Match.Groups['available'].Value
            $ReturnObject.PercentUsed = $Match.Groups['percent'].Value
            $ReturnObject.MountPoint  = $Match.Groups['mount'].Value
            
            $ReturnObjects += $ReturnObject
        }
    }

    return $ReturnObjects
}