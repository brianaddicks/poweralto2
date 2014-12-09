function Get-PaInterfaceCounter {
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
        $Command = "<show><counter><interface>$Name</interface></counter></show>"
    } else {
        $Command = "<show><counter><interface>all</interface></counter></show>"
    }

    $ResponseData = Invoke-PaOperation $Command
    $Global:test = $ResponseData

    function ProcessInterface ($entry,$hw) {
        $interfaceObject = New-Object PowerAlto.InterfaceStatus
        
        if ($hw) {
            Write-Verbose "hw found"

            $interfaceObject.InBytes  = $hw.entry.ibytes
            $interfaceObject.OutBytes = $hw.entry.obytes
            $interfaceObject.InDrops  = $hw.entry.idrops
            $interfaceObject.InErrors = $hw.entry.ierrors
        } else {
            $interfaceObject.InBytes  = $entry.ifnet.entry.ibytes
            $interfaceObject.OutBytes = $entry.ifnet.entry.obytes
            $interfaceObject.InDrops  = $entry.ifnet.entry.idrops
            $interfaceObject.InErrors = $entry.ifnet.entry.ierrors
        }

        $interfaceObject.Name          = $entry.ifnet.entry.name
        
        return $interfaceObject
    }

    return ProcessInterface $ResponseData.ifnet $ResponseData.hw
}
