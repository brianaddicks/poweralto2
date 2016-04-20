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

