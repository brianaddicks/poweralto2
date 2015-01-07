function Set-PaSecurityRule {
    [CmdletBinding()]
    Param (
        [Parameter(ParameterSetName='Object',Mandatory=$True,ValueFromPipeline=$True)]
        [PowerAlto.SecurityRule]$SecurityRule
    )

    $Action = "set"

    <#
    $Xpath  = "/config/devices/entry/vsys/entry/rulebase/security"
    $Xpath += "/entry[@name=`'$Name`'`]"

    $Action = "set"

    $ElementObject = New-Object Poweralto.SecurityRule

    $ElementObject.Name = $Name
    Write-Debug

    $ResponseData = Set-PaConfig -Xpath $Xpath -Action $Action -Element $ElementObject.PrintPlainXml() -Debug
    #>

    if ($SecurityRule) {
        $Xpath = $SecurityRule.XPath
        $ResponseData = Set-PaConfig -Xpath $Xpath -Action $Action -Element $SecurityRule.PrintPlainXml() -Debug
    }

    return $ResponseData
}
