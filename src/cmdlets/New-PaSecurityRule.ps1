function New-PaSecurityRule {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,Position=0)]
        [ValidatePattern('^[a-zA-Z0-9\-_\.]{1,31}$')]
        [string]$Name,

        [Parameter(Mandatory=$false,Position=1)]
        [ValidateSet("universal","intrazone","interzone")]
        [string]$RuleType = "universal",

        [Parameter(Mandatory=$false,Position=2)]
        [ValidateLength(1,255)]
        [string]$Description,

        [Parameter(Mandatory=$false,Position=3)]
        [array]$Tags,

        [Parameter(Mandatory=$false)]
        [switch]$Disabled
    )

    $NewRule             = New-Object PowerAlto.SecurityRule
    $NewRule.Name        = $Name
    $NewRule.RuleType    = $RuleType
    $NewRule.Description = $Description
    $NewRule.Tags        = $Tags
    $NewRule.Disabled    = $Disabled

    return $NewRule
}
