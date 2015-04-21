function Set-PaRuleUser {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,Position=0,ParameterSetName="security",ValueFromPipeline=$True)]
        [PowerAlto.SecurityRule]$Rule,

        [Parameter(Mandatory=$false,Position=1,ParameterSetName="security")]
        [array]$User = "any",

        [Parameter(Mandatory=$false,Position=2,ParameterSetName="security")]
        [array]$HipProfile = "any",

        [Parameter(Mandatory=$false)]
        [switch]$PassThru
    )

    $Rule.SourceUser = $User
    $Rule.HipProfile = $HipProfile

    if ($PassThru) {
        return $Rule
    }
}