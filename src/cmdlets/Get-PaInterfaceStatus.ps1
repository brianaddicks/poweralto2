function Get-PaInterfaceStatus {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,Position=0)]
        [ValidatePattern('^(ethernet\d+\/\d+(\.\d+)?|(loopback|tunnel|vlan)(\.\d+)?)$')]
        [string]$Name
    )

    if ($Ethernet -or $Loopback -or $Vlan -or $Tunnel) {
        $TypeSpecified = $True
    }

    if ($Name) {
        $Command = "<show><interface>$Name</interface></show>"
    } else {
        $Command = "<show><interface>all</interface></show>"
    }

    $ResponseData = Invoke-PaOperation $Command
    $Global:test = $ResponseData

    function ProcessInterface ($entry,$hw) {
        $interfaceObject = New-Object PowerAlto.InterfaceStatus
        
        if ($hw) {
            Write-Verbose "hw found"
            $interfaceObject.MacAddress = $hw.mac
            $interfaceObject.Speed      = $hw.speed
            $interfaceObject.Duplex     = $hw.duplex

            $interfaceObject.InBytes  = $entry.counters.hw.entry.ibytes
            $interfaceObject.OutBytes = $entry.counters.hw.entry.obytes
            $interfaceObject.InDrops  = $entry.counters.hw.entry.idrops
            $interfaceObject.InErrors = $entry.counters.hw.entry.ierrors
        } else {
            $interfaceObject.InBytes  = $entry.counters.ifnet.entry.ibytes
            $interfaceObject.OutBytes = $entry.counters.ifnet.entry.obytes
            $interfaceObject.InDrops  = $entry.counters.ifnet.entry.idrops
            $interfaceObject.InErrors = $entry.counters.ifnet.entry.ierrors
        }

        $interfaceObject.Name          = $entry.name
        $interfaceObject.Vsys          = $entry.vsys
        $interfaceObject.Mtu           = $entry.mtu
        $interfaceObject.VirtualRouter = $entry.vr
        $interfaceObject.Mode          = $entry.mode
        $interfaceObject.Zone          = $entry.zone
        $interfaceObject.Tag           = $entry.tag

        if ($entry.'dyn-addr'.member) {
            $interfaceObject.IpAddress = @($entry.'dyn-addr'.member)
        } elseif ($entry.addr.member) {
            $interfaceObject.IpAddress = @($entry.addr.member)
        }
        
        return $interfaceObject
    }

    return ProcessInterface $ResponseData.ifnet $ResponseData.hw
}
