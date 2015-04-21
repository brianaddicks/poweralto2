function Get-PaActiveRoute {
    [CmdletBinding()]
    Param (
    )

    $Command = "<show><routing><route></route></routing></show>"

    $ResponseData = Invoke-PaOperation $Command
    $Global:test = $ResponseData
    
    $Flags = @{ 'A' = 'active'
                '?' = 'loose'
                'C' = 'connect'
                'H' = 'host'
                'S' = 'static'
                '~' = 'internal'
                'R' = 'rip'
                'O' = 'ospf'
                'B' = 'bgp'
                'Oi' = 'ospf intra-area'
                'Oo' = 'ospf inter-area'
                'O1' = 'ospf ext-type-1'
                'O2' = 'ospf ext-type-2'
                'E' = 'ecmp' }


    $ResponseTable = @()

    foreach ($r in $ResponseData.entry) {
        $ResponseObject                = New-Object PowerAlto.ActiveRoute
        $EntryFlags = $r.flags.trim().split()
        $RealFlags = @()
        Foreach ($e in $EntryFlags) {
            $RealFlags += $Flags.get_item($e)
        }

        $ResponseObject.VirtualRouter  = $r.'virtual-router'
        $ResponseObject.Destination    = $r.destination
        $ResponseObject.NextHop        = $r.nexthop
        $ResponseObject.Metric         = $r.metric
        $ResponseObject.Flags          = $RealFlags
        $ResponseObject.Age            = $r.age
        $ResponseObject.Interface      = $r.interface

        $ResponseTable                += $ResponseObject
    }

    return $ResponseTable
}