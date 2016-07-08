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


$Device  = "10.1.10.11"
$ApiKey  = "LUFRPT04bnJpSU5HaWgvbUFmdEttWTBic3JqZ3g4U1k9YU9uZGNMM0pwMTd4ZHdjWGxNWTJ3b3hVQU9GeHFNdUU5OVgrYk9uakpUUT0="

$Connect = Get-PaDevice $Device -apikey $ApiKey

$Rule = Get-PaSecurityRule ExemptDesktops
$Addresses = $Rule.SourceAddress
$Resolved = Resolve-PaAddress $Addresses -ShowNames

$Device = "10.1.10.30"
$Connect = Get-PaDevice $Device -apikey $ApiKey