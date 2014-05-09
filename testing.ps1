$VerbosePreference = "Continue"
& ".\build\build.ps1"
$Device = "pegasus.addicks.us"
$ApiKey = "LUFRPT1PR2JtSDl5M2tjTktBeTkyaGZMTURTTU9BZm89OFA0Rk1WMS8zZGtKN0FmVjRqQ0lxVHlRcmgvSVRoUnlzMW5OckNhVEZUZz0="
ipmo C:\dev\poweralto2\poweralto2.psm1
Get-PaDevice $Device $ApiKey
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