function Set-PaSecurityRule {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True)]
        [string]$Name
    )

    $Xpath  = "/config/devices/entry/vsys/entry/rulebase/security"
    $Xpath += "/entry[@name=`'$Name`'`]"

    $Action = "set"

    $ElementObject = New-Object Poweralto.SecurityRule

    $ElementObject.Name = $Name
    Write-Debug

    $ResponseData = Set-PaConfig -Xpath $Xpath -Action $Action -Element $ElementObject.PrintPlainXml() -Debug
}
