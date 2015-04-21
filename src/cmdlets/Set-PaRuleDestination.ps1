function Set-PaRuleDestination {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,Position=0,ParameterSetName="security",ValueFromPipeline=$True)]
        [PowerAlto.SecurityRule]$Rule,

        [Parameter(Mandatory=$false,Position=1,ParameterSetName="security")]
        [array]$Zone = "any",

        [Parameter(Mandatory=$false,Position=2,ParameterSetName="security")]
        [array]$Address = "any",

        [Parameter(Mandatory=$false,Position=3,ParameterSetName="security")]
        [switch]$Negate,

        [Parameter(Mandatory=$false)]
        [switch]$PassThru
    )

    $Rule.DestinationZone    = $Zone
    $Rule.DestinationAddress = $Address
    $Rule.DestinationNegate  = $Negate

    if ($PassThru) {
        return $Rule
    }
}