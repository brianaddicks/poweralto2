###############################################
# Start of actual script


#$VerbosePreference = 'Continue'
#$Device            = "10.10.72.2"

$ParentDir  = $PSScriptRoot
#$ApiKeyPath = "$ParentDir\secret-apikey.txt"
#$ApiKey     = Get-Content $ApiKeyPath

$DeviceConnectionDetails = gc $ParentDir\secret-apikey.json | ConvertFrom-Json
$Device = $DeviceConnectionDetails.IpAddress
$ApiKey = $DeviceConnectionDetails.ApiKey

$IpMaskRx = [regex] '^(\d+\.){3}\d+\/\d{1,2}$'
$IpRx     = [regex] '^(\d+\.){3}\d+$'
$Connect       = Get-PaDevice -Device $Device -ApiKey $ApiKey

<#
ipmo C:\dev\poweralto2\PowerAlto2.psd1
ipmo ipv4math



$test = read-host "continue?"

$Rules         = Get-PaSecurityRule
$Routes        = Get-PaActiveRoute
$ValidRoutes   = $Routes | ? { $_.NextHop -notmatch 'vr\ '}
$Interfaces    = Get-PaInterfaceConfig
$Zones         = Get-PaZone
$Addresses     = Get-PaAddressObject
$AddressGroups = Get-PaAddressGroupObject
$Services      = Get-PaService
$ServicGroups  = Get-PaServiceGroup
$AppGroups     = Get-PaApplicationGroupObject
$NatPolicies   = Get-PaNatPolicy

$Test = read-host "continue?"

$ExpandedObjects = @()

function Resolve-PaAddressGroup {
[CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,Position=0)]
	    [string]$AddressGroup,

        [Parameter(Mandatory=$True,Position=1)]
	    [Array]$AddressGroupObjects,

        [Parameter(Mandatory=$True,Position=2)]
	    [Array]$AddressObjects
    )
    
    $ReturnObject = @()
    
    $Group = $AddressGroupObjects | ? { $_.Name -ceq $AddressGroup }

    foreach ($m in $Group.Members) {
        $GroupLookup = $AddressGroupObjects | ? { $_.Name -ceq $m }
        $AddressLookup = $AddressObjects | ? { $_.Name -ceq $m }
        if ($GroupLookup) {
            $ReturnObject += Resolve-PaAddressGroup $m $AddressGroupObjects $AddressObjects
        } elseif ($AddressLookup) {
            $ReturnObject += $AddressLookup.Address
        }
    }

    return $ReturnObject
}

foreach ($a in $Addresses) {
    $NewObject        = "" | Select Name,Value
    $NewObject.Name   = $a.Name
    $NewObject.Value  = $a.Address
    $ExpandedObjects += $NewObject
}

foreach ($a in $AddressGroups) {
    $NewObject        = "" | Select Name,Value
    $NewObject.Name   = $a.Name
    $NewObject.Value  = Resolve-PaAddressGroup $a.Name $AddressGroups $Addresses
    $ExpandedObjects += $NewObject
}


function Resolve-PaServiceGroup {
[CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,Position=0)]
	    [string]$ServiceGroup,

        [Parameter(Mandatory=$True,Position=1)]
	    [Array]$ServiceGroupObjects,

        [Parameter(Mandatory=$True,Position=2)]
	    [Array]$ServiceObjects
    )
    
    $ReturnObject = @()
    
    $Group = $ServiceGroupObjects | ? { $_.Name -ceq $ServiceGroup }

    foreach ($m in $Group.Members) {
        $GroupLookup   = $ServiceGroupObjects | ? { $_.Name -ceq $m }
        $ServiceLookup = $ServiceObjects | ? { $_.Name -ceq $m }
        if ($GroupLookup) {
            $ReturnObject += Resolve-PaServiceGroup $m $ServiceGroupObjects $ServiceObjects
        } elseif ($ServiceLookup) {
            $ReturnObject += "$($ServiceLookup.Protocol)/$($ServiceLookup.DestinationPort)"
        }
    }

    return $ReturnObject
}

foreach ($s in $Services) {
    $NewObject        = "" | Select Name,Value
    $NewObject.Name   = $s.Name
    $NewObject.Value  = $s.Protocol + '/' + $s.DestinationPort
    $ExpandedObjects += $NewObject
}

foreach ($s in $ServiceGroups) {
    $NewServiceMap        = "" | Select Name,Value
    $NewServiceMap.Name   = $s.Name
    $NewServiceMap.Value  = Resolve-PaServiceGroup $s.Name $ServiceGroups $Services
    $ExpandedObjects     += $NewServiceMap
}

$NewObject        = "" | Select Name,Value
$NewObject.Name   = 'service-http'
$NewObject.Value  = 'tcp/80,8080'
$ExpandedObjects += $NewObject

$NewObject        = "" | Select Name,Value
$NewObject.Name   = 'service-https'
$NewObject.Value  = 'tcp/443'
$ExpandedObjects += $NewObject

function Resolve-PaApplicationGroup {
[CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,Position=0)]
	    [string]$ApplicationGroup,

        [Parameter(Mandatory=$True,Position=1)]
	    [Array]$ApplicationGroupObjects
    )
    
    $ReturnObject = @()
    
    $Group = $ApplicationGroupObjects | ? { $_.Name -ceq $ApplicationGroup }

    if ($Group) {
        foreach ($m in $Group.Members) {
            $GroupLookup = $ApplicationGroupObjects | ? { $_.Name -ceq $m }
            if ($GroupLookup) {
                $ReturnObject += Resolve-PaApplicationGroup $m $ApplicationGroupObjects
            } else {
                $ReturnObject += $m
            }
        }
    } else {
        return $ApplicationGroup
    }

    return $ReturnObject
}

foreach ($a in $AppGroups) {
    $NewObject        = "" | Select Name,Value
    $NewObject.Name   = $a.Name
    $NewObject.Value  = Resolve-PaApplicationGroup $a.Name $AppGroups
    $ExpandedObjects += $NewObject
}

function CloneToDumbObject {
[CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,Position=0)]
	    [object]$Object,
        
        [Parameter(Mandatory=$False)]
	    [array]$AddProperties
    )
    
    $Properties = $Object | Get-Member -MemberType Property
    $NewProperties = @()
    foreach ($p in $Properties) {
        $NewProperties += $p.Name
    }
    
    $NewProperties += $AddProperties
    
    $NewObject = "" | Select $NewProperties
    foreach ($n in $NewProperties) {
        $NewObject.$n = $Object.$n
    }
    
    return $NewObject
}


function Resolve-PaRuleField {
[CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,Position=0)]
	    [object]$Rules,

        [Parameter(Mandatory=$True,Position=1)]
	    [Array]$Field,

        [Parameter(Mandatory=$True,Position=2)]
	    [Array]$ExpandedObjects
    )
    
    $StopWatch    = [System.Diagnostics.Stopwatch]::StartNew() # used by Write-Progress so it doesn't slow the whole function down
    $ReturnObject = @()
    $i            = 0
    
    foreach ($r in $Rules) {
        
        $i++
        $TotalCount      = $Rules.Count
        $PercentComplete = [math]::truncate($i / $TotalCount * 100)
        
        if ($StopWatch.Elapsed.TotalMilliseconds -ge 5000) {
		    Write-Progress -Activity "Resolving Field $Field. Rule: $($r.Name)" -Status "$PercentComplete% $i/$TotalCount" -PercentComplete $PercentComplete
            $StopWatch.Restart()
        }
        
        #Write-Verbose "Expanding $($r.name)"
        if ($r.gettype().NameSpace -eq 'PowerAlto') {
            $NewRule = CloneToDumbObject $r -AddProperties Notes,NatDest,NatName
        } else {
            $NewRule = $r
        }
        if (!($NewRule.$Field)) {
            Write-Verbose "$Field not found"
            $ReturnObject += $NewRule
        } else {
            foreach ($f in $NewRule.$Field) {
                Write-Verbose "Expanding $f"
                switch ($f) {
                    { ( $_ -eq 'any' ) -or
                      ( $_ -eq 'application-default') } {
                        $ValueRule         = $NewRule.psobject.copy()
                        $ValueRule.$Field  = $f
                        $ReturnObject     += $ValueRule
                    }
                    { $_ -match $IpMaskRx } {
                        $ValueRule         = $NewRule.psobject.copy()
                        $ValueRule.$Field  = $f
                        $ReturnObject     += $ValueRule
                    }
                    { $_ -match $IpRx } {
                        $ValueRule         = $NewRule.psobject.copy()
                        $ValueRule.$Field  = $f + '/32'
                        $ReturnObject     += $ValueRule
                    }
                    $null { $ReturnObject += $NewRule }
                    default {
                        Write-Verbose "Not a special case"
                        switch ($Field) {
                            { ( $_ -eq 'SourceZone' ) -or 
                              ( $_ -eq 'DestinationZone' ) -or
                              ( $_ -eq 'UrlCategory' ) -or
                              ( $_ -eq 'SourceUser' ) -or
                              ( $_ -eq 'HipProfile' ) } {
                                  $ValueRule         = $NewRule.psobject.copy()
                                  $ValueRule.$Field  = $f
                                  $ReturnObject     += $ValueRule
                              }
                            default {
                                $Lookup = ($ExpandedObjects | ? { $_.Name -ceq $f }).Value
                                if ($Lookup) {
                                    Write-Verbose "Lookup Found"
                                    foreach ($l in $Lookup) {
                                        $ValueRule         = $NewRule.psobject.copy()
                                        $ValueRule.$Field  = $l
                                        $ReturnObject     += $ValueRule
                                    }
                                } else {
                                    Write-Verbose "No Lookup Found"
                                    if ($Field -eq 'Application') {
                                        $NewRule.$Field = $f
                                        $ReturnObject += $NewRule
                                    } else {
                                        Throw "No Lookup Found for $Field`: $f"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    Write-Progress -Activity "Resolving Field $Field." -Status "$PercentComplete% $i/$TotalCount" -PercentComplete 100 -Completed
    return $ReturnObject
}

$test = Resolve-PaRuleField $Rules[0..2] SourceAddress $ExpandedObjects -verbose

$ResolvedRules = Resolve-PaRuleField $Rules SourceZone $ExpandedObjects
$ResolvedRules = Resolve-PaRuleField $ResolvedRules DestinationZone $ExpandedObjects
$ResolvedRules = Resolve-PaRuleField $ResolvedRules UrlCategory $ExpandedObjects
$ResolvedRules = Resolve-PaRuleField $ResolvedRules SourceUser $ExpandedObjects
$ResolvedRules = Resolve-PaRuleField $ResolvedRules HipProfile $ExpandedObjects
$ResolvedRules = Resolve-PaRuleField $ResolvedRules DestinationAddress $ExpandedObjects
$ResolvedRules = Resolve-PaRuleField $ResolvedRules SourceAddress $ExpandedObjects
$ResolvedRules = Resolve-PaRuleField $ResolvedRules Service $ExpandedObjects
$ResolvedRules = Resolve-PaRuleField $ResolvedRules Application $ExpandedObjects

$ResolvedNatPolicies = Resolve-PaRuleField $NatPolicies SourceZone $ExpandedObjects
$ResolvedNatPolicies = Resolve-PaRuleField $ResolvedNatPolicies DestinationZone $ExpandedObjects
$ResolvedNatPolicies = Resolve-PaRuleField $ResolvedNatPolicies SourceAddress $ExpandedObjects
$ResolvedNatPolicies = Resolve-PaRuleField $ResolvedNatPolicies SourceTranslatedAddress $ExpandedObjects
$ResolvedNatPolicies = Resolve-PaRuleField $ResolvedNatPolicies DestinationAddress $ExpandedObjects


$ZoneMaps      = @()
$InterfaceMaps = @()

foreach ($i in $Interfaces) {
    if ($i.IpAddress -notmatch $IpMaskRx) {
        $AddressLookup = $Addresses | ? { $_.name -eq $i.IpAddress }
        $i.IpAddress   = $AddressLookup.Address
    }

    $InterfaceMap         = "" | Select Name,Routes
    $InterfaceMap.Name    = $i.Name
    $InterfaceMap.Routes  = @()
    $InterfaceMaps       += $InterfaceMap

    foreach ($r in $ValidRoutes) {
        if ($r.Interface -eq $i.Name) {
            $InterfaceMap.Routes += $r.Destination
            $ValidRoutes = $ValidRoutes | ? { $_ -ne $r }
        } else {
            if ($i.IpAddress -and (Test-IpRange -ContainingNetwork $i.IpAddress -ContainedNetwork $r.Destination)) {
                $InterfaceMap.Routes += $r.Destination
                $ValidRoutes = $ValidRoutes | ? { $_ -ne $r }
            }
        }
    }
}

foreach ($z in $Zones) {
    $ZoneMap        = "" | Select Name,Value
    $ZoneMap.Name   = $z.Name
    $ZoneMap.Value  = @()
    $ZoneMaps      += $ZoneMap

    foreach ($i in $z.Interfaces) {
        $InterfaceLookup = $InterfaceMaps | ? { $_.Name -eq $i }
        $ZoneMap.Value += $InterfaceLookup.Routes
    }
}

$NewZoneMap        = "" | Select Name,Value
$NewZoneMap.Name   = 'any'
$NewZoneMap.Value  = $ZoneMaps.Value | Select -Unique
$ZoneMaps         += $NewZoneMap


function Test-PaZoneForRoute {
    Param (
        [Parameter(Mandatory=$True,Position=0)]
	    [string]$Zone,

        [Parameter(Mandatory=$True,Position=1)]
	    [Array]$ZoneMap,
        
        [Parameter(Mandatory=$True,Position=2)]
	    [string]$Network
    )
    
    $IpMaskRx = [regex] '(?<ip>(\d+\.){3}\d+)(\/(?<mask>\d{1,2}))?'
    $Match    = $IpMaskRx.Match($Network)
    
    Write-Verbose "Checking $Network as valid Ip"
    if ($Match.Success) {
        $IpAddress = $Match.Groups['ip'].Value
        try {
            $CheckIp =  [Net.IPAddress]$IpAddress
        } catch {
            Throw "Not a Valid IP/Network Address"
        }
        if ($Match.Groups['mask'].Success) {
            $Mask = $Match.Groups['mask'].Value
            if (([int]$Mask -gt 32) -or ([int]$Mask -lt 0)) {
                Throw "Not a Valid Mask Length"
            }  
        } else {
            $Network += '/32'
        }
    } else {
        Throw "Network must be an IP Address or CIDR notation."
    }
        
    $ZoneLookup = $ZoneMap | ? { $_.Name -eq $Zone }
    if (!($ZoneLookup)) {
        Throw "Zone `"$Zone`" not found."
    } else {
        $ValidRoute = $false
        foreach ($r in $ZoneLookup.Value) {
            Write-Verbose "Looking for $Network in $r, zone $Zone"
            $r
            $ValidRoute = $ValidRoute -or (Test-IpRange -ContainingNetwork $r -ContainedNetwork $Network)
        }
    }
    return $ValidRoute
}


function Check-PaRuleRoute {
[CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,Position=0)]
	    [object]$Rules,

        [Parameter(Mandatory=$True,Position=1)]
	    [Array]$RouteMap
    )
    
    $StopWatch    = [System.Diagnostics.Stopwatch]::StartNew() # used by Write-Progress so it doesn't slow the whole function down
    $ReturnObject = @()
    $i            = 0
    
    foreach ($r in $Rules) {
        
        # Progress Bar
        $i++
        $TotalCount      = $Rules.Count
        $PercentComplete = [math]::truncate($i / $TotalCount * 100)
        
        if ($StopWatch.Elapsed.TotalMilliseconds -ge 5000) {
		    Write-Progress -Activity "Resolving Field $Field. Rule: $($r.Name)" -Status "$PercentComplete% $i/$TotalCount" -PercentComplete $PercentComplete
            $StopWatch.Restart()
        }
        
        $NewRule = $r.psobject.copy()
        foreach ($Field in @('Source','Destination')) {
            foreach ($Zone in $r."$Field`Zone") {
                $AddressToCheck = $r."$Field`Address"
                $IsValid = $False
                if ($AddressToCheck -eq 'any') {
                    $IsValid = $True
                } elseif ($r.SourceNegate -or $r.DestinationNegate) {
                    $IsValid = $True
                } else {
                    $IsValid = $IsValid -and (Test-PaZoneForRoute $Zone $RouteMap $AddressToCheck)
                }
            }
        }
        if (!($IsValid)) {
            $NewRule.Notes = "invalid source/dest"
        }
        $ReturnObject += $NewRule
    }
    return $ReturnObject
}

#$ValidatedRules = Check-PaRuleRoute $ResolvedRules $ZoneMaps

$StaticNats = $ResolvedNatPolicies | ? { ($_.SourceTranslationType -eq 'StaticIp') -and ($_.IsBidirectional) }

foreach ($Policy in $StaticNats) {
    Write-Host $Policy.Number
    $Lookup = $ResolvedRules | ? { (($_.SourceZone -eq $Policy.DestinationZone) -or ($_.SourceZone -eq 'any')) -and
                                   (($_.DestinationZone -eq $Policy.SourceZone) -or ($_.DestinationZone -eq 'any')) -and
                                   ($_.DestinationAddress -eq $Policy.SourceTranslatedAddress) }
                                   
    foreach ($l in $Lookup) {
        $l.NatDest = $Policy.SourceAddress
        $l.NatName = $Policy.name
        if ($Policy.Disabled) {
            $l.Notes = "Nat Disabled"
        }
    }
}

$ResolvedRules | select Number,Name,Disabled,Allow,Source*,Dest*,UrlCategory,NatDest,Service,Application,*Profile*,NatName,Notes | Export-Csv C:\temp\rules.csv -NoTypeInformation
#>