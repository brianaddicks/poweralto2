function Set-PaRuleServiceUrl {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,Position=0,ParameterSetName="security",ValueFromPipeline=$True)]
        [PowerAlto.SecurityRule]$Rule,

        [Parameter(Mandatory=$false,Position=1,ParameterSetName="security")]
        [array]$Service,

        [Parameter(Mandatory=$false,Position=2,ParameterSetName="security")]
        [array]$UrlCategory,

        [Parameter(Mandatory=$false)]
        [switch]$PassThru
    )

    if ($Service)     { $Rule.Service = $Service }
    if ($UrlCategory) { $Rule.UrlCategory = $UrlCategory }

    if ($PassThru) {
        return $Rule
    }
}