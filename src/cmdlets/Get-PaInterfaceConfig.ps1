function Get-PaInterfaceConfig {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False,Position=0)]
        #[ValidatePattern("\w+|(\w\.)+\w")]
        [string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    
    $ElementName = "network/interface"
    $Xpath = "/config/devices/entry/$ElementName"
    $InterfaceTypeRx = [regex] '(?<type>loopback|vlan|tunnel|ethernet)(?<num>\d+\/\d+|\.\d+)?(?<sub>\.\d+)?'

    if ($Name) {
        $InterfaceMatch = $InterfaceTypeRx.Match($Name)
        $InterfaceType  = $InterfaceMatch.Groups['type'].Value

        Write-Verbose $InterfaceMatch.Value

        switch ($InterfaceType) {
            { ($_ -eq "loopback") -or
              ($_ -eq "vlan") -or
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

    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."
    $Global:test = $ResponseData

    function ProcessInterface ($entry) {
        $interfaceObject             = New-Object PowerAlto.InterfaceConfig
        $interfaceObject.Name        = $entry.name
        $interfaceObject.Comment     = $entry.comment
        $InterfaceObject.AdminSpeed  = $Entry.'link-speed'
        $InterfaceObject.AdminDuplex = $Entry.'link-duplex'
        $InterfaceObject.AdminState  = $Entry.'link-state'

        if ($entry.layer3 -or ($entry.firstchild.name -eq 'tap')) {
            $interfaceObject.MgmtProfile    = $entry.layer3.'interface-management-profile'
            $interfaceObject.NetflowProfile = $entry.layer3.'netflow-profile'
            $interfaceObject.IpAddress      = $entry.layer3.ip.entry.name

            if ($entry.layer3) {
                $interfaceObject.Type = 'layer3'
            } elseif ($entry.firstchild.name -eq 'tap') {
                $interfaceObject.Type = 'tap'
            }

            if ($entry.layer3.'untagged-sub-interface' -eq 'yes') {
                $interfaceObject.UntaggedSub = $true
            }

            if ($entry.layer3.'dhcp-client'.enable -eq 'yes') {
                $interfaceObject.IsDhcp = $true

                if ($entry.layer3.'dhcp-client'.'create-default-route' -eq 'yes') {
                    $interfaceObject.CreateDefaultRoute = $true
                }
            }
        } elseif ($entry.ip.entry.name) {
            $interfaceObject.MgmtProfile = $entry.'interface-management-profile'
            $interfaceObject.IpAddress   = $entry.ip.entry.name
            $interfaceObject.Tag         = $entry.tag

            switch ($entry.name) {
                { $_ -match 'ethernet' } {
                    $interfaceObject.Type = 'subinterface'
                }
            }
        }

        return $interfaceObject
    }


    ###############################################################################
    # Process Response

    if ($Name) {
        if ($ResponseData.entry) {
            ProcessInterface $ResponseData.entry
        } else {
            ProcessInterface $ResponseData.$Name
        }

        return $InterfaceObject
    } else {
        $InterfaceObjects = @()

        ###############################################################################
        # Ethernet Interfaces

        Write-Verbose '## Ethernet Interfaces ##'
        foreach ($e in $ResponseData.interface.ethernet.entry) {
            if ($e.layer3 -or ($e.firstchild.name -eq 'tap')) {
                Write-Verbose $e.name
                $InterfaceObjects += ProcessInterface $e
                if ($e.layer3.units) {
                    foreach ($u in $e.layer3.units.entry) {
                        Write-Verbose $u.name
                        $InterfaceObjects += ProcessInterface $u
                    }
                }
            }
        }

        ###############################################################################
        # Loopback Interfaces

        Write-Verbose '## Loopback Interfaces ##'
        foreach ($e in $ResponseData.interface.loopback) {
            Write-Verbose 'loopback'
            $InterfaceObjects += ProcessInterface $e
            if ($e.units) {
                foreach ($u in $e.units.entry) {
                    Write-Verbose $u.name
                    $InterfaceObjects += ProcessInterface $u
                }
            }
        }

        ###############################################################################
        # Vlan Interfaces

        Write-Verbose '## Vlan Interfaces ##'
        foreach ($e in $ResponseData.interface.vlan) {
            $InterfaceObjects += ProcessInterface $e
            Write-Verbose 'vlan'
            if ($e.units) {
                foreach ($u in $e.units.entry) {
                    Write-Verbose $u.name
                    $InterfaceObjects += ProcessInterface $u
                }
            }
        }

        ###############################################################################
        # Tunnel Interfaces

        Write-Verbose '## Tunnel Interfaces ##'
        foreach ($e in $ResponseData.interface.tunnel) {
            Write-Verbose "tunnel"
            $InterfaceObjects += ProcessInterface $e
            if ($e.units) {
                foreach ($u in $e.units.entry) {
                    Write-Verbose $u.name
                    $InterfaceObjects += ProcessInterface $u
                }
            }
        }
        
        return $InterfaceObjects
    }
}
