[CmdletBinding()]
Param (
    [Parameter(Mandatory=$False,Position=0)]
	[switch]$PushToStrap
)

$VerbosePreference = "Continue"
if ($PushToStrap) {
    & ".\buildmodule.ps1" -PushToStrap
} else {
    & ".\buildmodule.ps1"
}
ipmo C:\dev\poweralto2\poweralto2.psd1


$Device  = "10.10.72.2"
$ApiKey  = "LUFRPT1SanJaQVpiNEg4TnBkNGVpTmRpZTRIamR4OUE9Q2lMTUJGREJXOCs3SjBTbzEyVSt6UT09"
$Device  = "10.88.72.2"
$ApiKey  = "LUFRPT1jcFBhMnp2WGFrSmFsbVVHZ2k5Nm1sQTlheUE9WDI0dENOdnplTlFBRnZQd3I5Zm5FUUhYbkF2c1RnTlNPOTZIdkx0V0xUUT0="
$Connect = Get-PaDevice $Device -apikey $ApiKey


$Now       = Get-Date
$Date      = get-date $now.AddDays(-7) -format "yyyy/MM/dd HH:mm:ss"
$Query     = "(( eventid eq globalprotectgateway-auth-succ ) and ( receive_time geq '$Date' ))" 
$LogJob    = Get-PaLog -LogType system -Query $Query -WaitForJob

$UsernameRx = [regex] "User\ name:\ ([^\,]+?),"
$Users = @()
foreach ($Entry in $Logjob.log.logs.entry) {
    $UsernameMatch = $UsernameRx.Match($Entry.opaque)
    if ($UsernameMatch.Success) {
        $Users += $UsernameMatch.Groups[1].Value
    }
}

$Users | Select -unique

#$LogResult = Get-PaLog -Action get -job $LogJob.job 



#( eventid eq globalprotectgateway-auth-succ ) and ( receive_time geq '2016/04/13 09:18:00' )


#$Device = "10.0.72.2"
#$Device = "10.88.128.91"
#$ApiKey = "LUFRPT1XODhhTmV5M3dXMHBYQ2o1bnNUMnc1SEtSb1U9c3JuMTV2Um8yNlRPaTI3UlV1Y2xZSkRQODBLVEIwUVNIbDhtTENNYWhZdz0="
#$ApiKey = "LUFRPT14MW5xOEo1R09KVlBZNnpnemh0VHRBOWl6TGM9bXcwM3JHUGVhRlNiY0dCR0srNERUQT09"

#IST
#$Device            = '10.0.72.250'
#$ApiKey            = 'LUFRPT1CNGVJc3cveXA1OEppdHZxUnRaS1U0YlFTT0E9U2ZoaERxS205ME03RGttWWRxd1UrUT09'

#Get-PaDevice $Device -apikey $ApiKey
<#
Get-PaApplicationGroupObject


<#
$global:TestRule                    = new-object PowerAlto.SecurityRule
$global:TestRule.Name               = "newrule"
$global:TestRule.Description        = "this is a description"
$global:TestRule.Tags               = @("tag1","tag2","newtag1")
$global:TestRule.SourceZone         = "lan"
$global:TestRule.SourceAddress      = "10.10.42.11/32"
$global:TestRule.SourceNegate       = $True
$global:TestRule.SourceUser         = "any"
$global:TestRule.HipProfile         = "no-hip"
$global:TestRule.DestinationZone    = "net"
$global:TestRule.DestinationAddress = "any"
$global:TestRule.DestinationNegate  = $False
$global:TestRule.Application        = @("active-directory","dns","ldap","ping")
$global:TestRule.Service            = "application-default"
$global:TestRule.UrlCategory        = "any"
$global:TestRule.Allow              = $True
$global:TestRule.ProfileGroup       = "threat-and-vuln"
$global:TestRule.LogAtSessionStart  = $False
$global:TestRule.LogAtSessionEnd    = $True
$global:TestRule.LogForwarding      = "log-all"
$global:TestRule.Schedule           = "test"
$global:TestRule.QosType            = "ip-dscp"
$global:TestRule.QosMarking         = "af11"
$global:TestRule.DisableSRI         = $False
$global:TestRule.Disabled           = $True
#>

#cp C:\dev\poweralto2\PowerAlto2.psm1 \\athena2\c$\_strap\poweralto2
#cp C:\dev\poweralto2\PowerAlto2.dll \\athena2\c$\_strap\poweralto2
#cp C:\dev\poweralto2\PowerAlto2.psd1 \\athena2\c$\_strap\poweralto2

<#
#get-padiskspace
$global:test = new-object poweralto.Zone
$global:test.name = "new_zone"
$global:test.ZoneType = "layer3"
$global:test.Interfaces = "eth1/1","eth1/2"
$global:test.UserIdAclInclude = "10.10.10.0/24"
$global:test.UserIdAclExclude = "10.90.0.0/24"


$global:test = New-PaSecurityRule -Name poweralto-test2 -RuleType Universal -Description "test description" -tags "tag1","tag2" -Disabled
$global:test | Set-PaRuleSource -Zone lan -Address '10.10.10.10/32' -Negate
$global:test | Set-PaRuleDestination -Zone net
$global:test | Set-PaRuleApplication -Application 'active-directory','dns','ldap','ping'
$global:test | Set-PaRuleServiceUrl -Service 'application-default'
$global:test | Set-PaSecurityRuleActions -Action allow
$global:test | Set-PaSecurityRuleActions -LogEnd -LogForwarding 'log-all'
$global:test | Set-PaSecurityRuleActions -ProfileGroup 'threat-and-vuln'
$global:test | Set-PaSecurityRuleActions -Schedule test
$global:test | Set-PaSecurityRuleActions -DscpMarking af11




#>













