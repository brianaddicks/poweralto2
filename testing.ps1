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


$Device  = "panorama.gmc.cc.ga.us"
$ApiKey  = "LUFRPT1oWlhGSS9iaXRmRUpBREhPemFINkhQdGNlVTA9cVhNb2swbU5ZYXNTUlVnanBKT2VndDZMRno0T3RVbWZDeHd6S2docGtCWT0="

$Connect = Get-PaDevice $Device -apikey $ApiKey
