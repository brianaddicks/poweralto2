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
$Query     = "((( eventid eq globalprotectgateway-logout-succ ) or ( eventid eq globalprotectgateway-auth-succ )) and ( receive_time geq '$Date' ))"
#$Query     = "((( eventid eq globalprotectgateway-logout-succ )) and ( receive_time geq '$Date' ))" 
$LogJob    = Get-PaLog -LogType system -Query $Query -WaitForJob -NumberOfLogs 5000

$UsernameRx = [regex] "User\ name:\ ([^\,]+?),"
$Users = @()
foreach ($Entry in ($Logjob.log.logs.entry | sort time_generated)) {
    $UsernameMatch = $UsernameRx.Match($Entry.opaque)
    $Entry | Select time_generated,eventid,@{Name="user";Expression={$UsernameRx.Match($Entry.opaque).Groups[1].Value}}
    if ($UsernameMatch.Success) {
        $Users += $UsernameMatch.Groups[1].Value
    }
}