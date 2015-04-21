function Set-PaSecurityRuleActions {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$True)]
        [PowerAlto.SecurityRule]$Rule,

        #################################################################

        [Parameter(Mandatory=$true,Position=1,ParameterSetName="Action")]
        [ValidateSet("allow","deny")]
        [array]$Action,

        #################################################################
        
        [Parameter(Mandatory=$false,ParameterSetName="Log")]
        [switch]$LogStart,

        [Parameter(Mandatory=$false,ParameterSetName="Log")]
        [switch]$LogEnd,

        [Parameter(Mandatory=$false,ParameterSetName="Log")]
        [string]$LogForwarding,

        #################################################################

        [Parameter(Mandatory=$True,ParameterSetName="ProfileGroup")]
        [string]$ProfileGroup,

        #################################################################

        [Parameter(Mandatory=$False,ParameterSetName="Profiles")]
        [string]$Antivirus,

        [Parameter(Mandatory=$False,ParameterSetName="Profiles")]
        [string]$VulnerabilityProtection,

        [Parameter(Mandatory=$False,ParameterSetName="Profiles")]
        [string]$AntiSpyware,

        [Parameter(Mandatory=$False,ParameterSetName="Profiles")]
        [string]$UrlFiltering,

        [Parameter(Mandatory=$False,ParameterSetName="Profiles")]
        [string]$FileBlocking,

        [Parameter(Mandatory=$False,ParameterSetName="Profiles")]
        [string]$DataFiltering,

        #################################################################

        [Parameter(Mandatory=$False,ParameterSetName="Schedule")]
        [string]$Schedule,

        #################################################################

        [Parameter(Mandatory=$False,ParameterSetName="Dscp")]
        [ValidateSet("af11","af12","af13","af21","af22","af23","af31",
                     "af32","af33","af41","af42","af43")]
        [string]$DscpMarking,

        #################################################################

        [Parameter(Mandatory=$False,ParameterSetName="IpPrecedence")]
        [ValidateSet("af11","af12","af13","af21","af22","af23","af31",
                     "af32","af33","af41","af42","af43","cs0","cs1",
                     "cs2","cs3","cs4","cs5","cs6","cs7","ef")]
        [string]$IpPrecedence,

        #################################################################
        
        [Parameter(Mandatory=$false,ParameterSetName="SRI")]
        [switch]$DisableSRI,

        #################################################################

        [Parameter(Mandatory=$false)]
        [switch]$PassThru
    )

    if ($Action) {
        if ($Action -eq "allow") { $Rule.Allow = $true } 
                            else { $Rule.Allow = $false }
    }

    if ($LogStart)      { $Rule.LogAtSessionStart = $true }
    if ($LogEnd)        { $Rule.LogAtSessionEnd   = $true }
    if ($LogForwarding) { $Rule.LogForwarding     = $LogForwarding }

    if ($ProfileGroup)  { $Rule.ProfileGroup = $ProfileGroup }

    if ($Antivirus)                { $Rule.AntivirusProfile     = $Antivirus }
    if ($VulnerabilityProtection)  { $Rule.VulnerabilityProfile = $VulnerabilityProtection }
    if ($AntiSpyware)              { $Rule.AntiSpywareProfile   = $AntiSpyware }
    if ($UrlFiltering)             { $Rule.UrlFilteringProfile  = $UrlFiltering }
    if ($FileBlocking)             { $Rule.FileBlockingProfile  = $FileBlocking }
    if ($DataFiltering)            { $Rule.DataFilteringProfile = $DataFiltering }

    if ($Schedule) { $Rule.Schedule = $Schedule }

    if ($DscpMarking) {
        $Rule.QosType    = 'ip-dscp'
        $Rule.QosMarking = $DscpMarking
    }

    if ($IpPrecedence) {
        $Rule.QosType    = 'ip-precedence'
        $Rule.QosMarking = $IpPrecedence
    }

    if ($DisableSRI) { $Rule.DisableSRI = $true }

    if ($PassThru) {
        return $Rule
    }
}