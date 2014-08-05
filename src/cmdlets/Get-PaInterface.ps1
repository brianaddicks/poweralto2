function Get-PaInterface {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False,Position=0)]
        [ValidatePattern("\d+\.\d+\.\d+\.\d+|(\w\.)+\w")]
        [string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $ElementName = "network/interface"
    $Xpath = "/config/devices/entry/$ElementName"
    $InterfaceTypeRx = [regex] '(?<type>loopback|vlan|tunnel|ethernet)(?<num>\d+\/\d+|\.\d+)?(?<sub>\.\d+)?'

    if ($Name) {
        $InterfaceMatch = $InterfaceTypeRx.Match($Name)
        $InterfaceType  = $InterfaceMatch.Groups['type'].Value

        Write-Verbose $InterfaceMatch.Value

        switch ($InterfaceType) {
            { ($_ -eq "loopback") -or 
              ($_ -eq "tunnel") } {
                if ($InterfaceMatch.Groups['num'].Success) {
                    $Xpath += "/$InterfaceType/units/entry[@name='$Name']"
                } else {
                    $Xpath += "/$Name"
                }
            }
            ethernet {
                $Xpath += "/$InterfaceType/entry[@name='$($InterfaceMatch.Groups['type'].Value)$($InterfaceMatch.Groups['num'].Value)']"
                if ($InterfaceMatch.Groups['sub'].Success) {
                    $Xpath += "/layer3/units/entry[@name='$Name']"
                }
            }
            default {
                $Xpath += "/$InterfaceType/entry[@name='$Name']"
            }
        }
    }

    Write-Verbose $Xpath

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."
    $Global:test = $ResponseData

    if ($Name) {
        $InterfaceObject             = New-Object PowerAlto.Interface
        $InterfaceObject.Name        = $Name
        $InterfaceObject.Comment     = $ResponseData.entry.comment
        $InterfaceObject.MgmtProfile = $ResponseData.entry.'interface-management-profile'
        $InterfaceObject.IpAddress   = $ResponseData.entry.ip.entry.name
        $InterfaceObject.Tag         = $ResponseData.entry.tag

        if ($ResponseData.entry.layer3) {
            $InterfaceObject.Type = 'layer3'
            $Entry = $ResponseData.entry

            if ($Entry.layer3.'dhcp-client'.enable -eq 'yes') {
                $InterfaceObject.IsDhcp = $true
            }

            if ($Entry.layer3.'dhcp-client'.'create-default-route' -eq 'yes') {
                $InterfaceObject.CreateDefaultRoute = $true
            }

            $InterfaceObject.AdminSpeed     = $Entry.'link-speed'
            $InterfaceObject.AdminDuplex    = $Entry.'link-duplex'
            $InterfaceObject.AdminState     = $Entry.'link-state'
            $InterfaceObject.IpAddress      = $Entry.layer3.ip.entry.name
            $InterfaceObject.NetflowProfile = $Entry.layer3.'netflow-profile'
            $InterfaceObject.MgmtProfile    = $Entry.layer3.'interface-management-profile'

            if ($Entry.layer3.'untagged-sub-interface' -eq 'yes') {
                $InterfaceObject.UntaggedSub = $true
            }

        }

        return $InterfaceObject
    }


    <#
    if ($ResponseData.$ElementName) { $ResponseData = $ResponseData.$ElementName.entry } `
                               else { $ResponseData = $ResponseData.entry             }

    $ResponseTable = @()
    foreach ($r in $ResponseData) {
        $ResponseObject = New-Object PowerAlto.Service
        Write-Verbose "Creating new Service object"
        
        $ResponseObject.Name = $r.name
        Write-Verbose "Setting Service Name $($r.name)"
        
        $Protocol = ($r.protocol | gm -Type Property).Name

        $ResponseObject.Protocol        = $Protocol
        $ResponseObject.DestinationPort = $r.protocol.$Protocol.port

        if ($r.protocol.$Protocol.'source-port') { $ResponseObject.SourcePort      = $r.protocol.$Protocol.'source-port' }

        $ResponseObject.Tags            = HelperGetPropertyMembers $r tag
        $ResponseObject.Description     = $r.description


        $ResponseTable += $ResponseObject
        Write-Verbose "Adding object to array"
    }
    
    return $ResponseTable#>
}
