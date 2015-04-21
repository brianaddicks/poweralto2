function Set-PaRuleApplication {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,Position=0,ParameterSetName="security",ValueFromPipeline=$True)]
        [PowerAlto.SecurityRule]$Rule,

        [Parameter(Mandatory=$false,Position=1,ParameterSetName="security")]
        [array]$Application = "any",

        [Parameter(Mandatory=$false)]
        [switch]$PassThru
    )

    $Rule.Application = $Application

    if ($PassThru) {
        return $Rule
    }
}