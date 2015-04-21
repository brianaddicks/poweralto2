function Get-PaZone {
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $Xpath = "/config/devices/entry/vsys/entry/zone"

    if ($Name) { $Xpath += "/entry[@name='$Name']" }

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    
    $ZoneData = Get-PaConfig -Xpath $Xpath -Action $Action

    if ($ZoneData.zone) { $ZoneData = $ZoneData.zone.entry } `
                   else { $ZoneData = $ZoneData.entry      }
        

    $ZoneTable = @()
    foreach ($z in $ZoneData) {
        $ZoneObject = New-Object PowerAlto.Zone

        $ZoneObject.Name                  = $z.name
        $ZoneObject.LogSetting            = $z.network.'log-setting'
        $ZoneObject.ZoneProtectionProfile = $z.network.'zone-protection-profile'
        $ZoneObject.UserIdAclInclude      = $z.'user-acl'.'include-list'.member
        $ZoneObject.UserIdAclExclude      = $z.'user-acl'.'exclude-list'.member

        if ($z.'enable-user-identification') {
            $ZoneObject.EnableUserId = $true
        }


        $IsLayer3 = $z.network.layer3
        if ($IsLayer3) {
            $ZoneObject.ZoneType = "layer3"
            $ZoneObject.Interfaces = $IsLayer3.member
        }

        $ZoneTable += $ZoneObject
    }

    return $ZoneTable

}
