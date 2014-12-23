function Get-PaInterfaceCounter {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,Position=0)]
        [ValidatePattern('^(ethernet\d+\/\d+(\.\d+)?|(loopback|tunnel|vlan|ae\d)(\.\d+)?)$')]
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

    function ProcessInterface ($entry) {
        $interfaceObject = New-Object PowerAlto.InterfaceStatus
        
        #tunnel:      .ifnet.entry
        #loopback:    .ifnet.entry
        #subinterface .ifnet.entry
        #vlan:        .hw.entry
        #ae:          .hw.entry
        #ethernet:    .hw.entry



        if ($entry.hw.entry) {
            Write-Verbose "hw found"

            $interfaceObject.InBytes  = $entry.hw.entry.ibytes
            $interfaceObject.OutBytes = $entry.hw.entry.obytes
            $interfaceObject.InDrops  = $entry.hw.entry.idrops
            $interfaceObject.InErrors = $entry.hw.entry.ierrors
        } else {
            Write-Verbose "hw not found"

            $interfaceObject.InBytes  = $entry.ifnet.entry.ibytes
            $interfaceObject.OutBytes = $entry.ifnet.entry.obytes
            $interfaceObject.InDrops  = $entry.ifnet.entry.idrops
            $interfaceObject.InErrors = $entry.ifnet.entry.ierrors
        }

        $interfaceObject.Name          = $entry.ifnet.entry.name
        
        return $interfaceObject
    }

    return ProcessInterface $ResponseData
}
