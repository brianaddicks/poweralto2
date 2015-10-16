###############################################
# Start of actual script


$VerbosePreference = 'Continue'
#$Device            = "10.10.72.2"

$ParentDir  = $PSScriptRoot
#$ApiKeyPath = "$ParentDir\secret-apikey.txt"
#$ApiKey     = Get-Content $ApiKeyPath

$DeviceConnectionDetails = gc $ParentDir\secret-apikey.json | ConvertFrom-Json
$Device = $DeviceConnectionDetails.IpAddress
$ApiKey = $DeviceConnectionDetails.ApiKey

$IpMaskRx = [regex] '(\d+\.){3}\d+\/\d{1,2}'

ipmo C:\dev\poweralto2\PowerAlto2.psd1
ipmo ipv4math

$Connect       = Get-PaDevice -Device $Device -ApiKey $ApiKey
$Rules         = Get-PaSecurityRule
$Routes        = Get-PaActiveRoute
$ValidRoutes   = $Routes | ? { $_.NextHop -notmatch 'vr\ '}
$Interfaces    = Get-PaInterfaceConfig
$Zones         = Get-PaZone
$Addresses     = Get-PaAddressObject
$AddressGroups = Get-PaAddressGroupObject
$Services      = Get-PaService
$ServicGroups  = Get-PaServiceGroup

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

$RuleOutput = $rules | select Name,SourceZone,SourceAddress,DestinationZone,DestinationAddress,Application,Service,Allow
<#
function AddDivTags {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,Position=0)]
	    [Array]$DivContent,

        [Parameter(Mandatory=$True,Position=1)]
	    [Array]$DivClass
    )

    $Exclusions = @('any',
                    'application-default')

    $ReturnString = ""
    foreach ($d in $DivContent) {
        if ($Exclusions -contains $d) {
            $ReturnString += "<div>"
        } else {
            $ReturnString += "<div class='$DivClass'>"
        }
        $ReturnString += $d
        $ReturnString += "</div>"
    }
    return $ReturnString
}

$RuleOutput = $Rules | `
              Select Name,
              @{Name = 'SourceZone'; Expression = {AddDivTags $_.SourceZone zones}},
              @{Name = 'SourceAddress'; Expression = {AddDivTags $_.SourceAddress addresses}},
              @{Name = 'DestinationZone'; Expression = {AddDivTags $_.DestinationZone zones}},
              @{Name = 'DestinationAddress'; Expression = {AddDivTags $_.DestinationAddress addresses}},
              @{Name = 'Application'; Expression = {[string]::join("<br>",$_.Application)}},
              @{Name = 'Service'; Expression = {AddDivTags $_.Service services}},
              @{Name = 'Action'; Expression = {if ($_.Allow) { 'allow'} else { 'deny' }}}

#Get-HtmlList $RuleOutput | Out-File 'c:\temp\test.html'

$OutputFileName = 'c:\temp\test.html'
#>

####################################################
# mappings

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
    
    $Group = $AddressGroupObjects | ? { $_.Name -eq $AddressGroup }

    foreach ($m in $Group.Members) {
        $GroupLookup = $AddressGroupObjects | ? { $_.Name -eq $m }
        $AddressLookup = $AddressObjects | ? { $_.Name -eq $m }
        if ($GroupLookup) {
            $ReturnObject += Resolve-PaAddressGroup $m $AddressGroupObjects $AddressObjects
        } elseif ($AddressLookup) {
            $ReturnObject += $AddressLookup.Address
        }
    }

    return $ReturnObject
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
    
    $Group = $ServiceGroupObjects | ? { $_.Name -eq $ServiceGroup }

    foreach ($m in $Group.Members) {
        $GroupLookup   = $ServiceGroupObjects | ? { $_.Name -eq $m }
        $ServiceLookup = $ServiceObjects | ? { $_.Name -eq $m }
        if ($GroupLookup) {
            $ReturnObject += Resolve-PaServiceGroup $m $ServiceGroupObjects $ServiceObjects
        } elseif ($ServiceLookup) {
            $ReturnObject += "$($ServiceLookup.Protocol)/$($ServiceLookup.DestinationPort)"
        }
    }

    return $ReturnObject
}

$ServiceMaps = @()

foreach ($a in $ServiceGroups) {
    $NewServiceMap        = "" | Select Name,Value
    $NewServiceMap.Name   = $a.Name
    $NewServiceMap.Value  = Resolve-PaServiceGroup $a.Name $ServiceGroups $Services
    $ServiceMaps         += $NewServiceMap
}

foreach ($a in $Services) {
    $NewServiceMap        = "" | Select Name,Value
    $NewServiceMap.Name   = $a.Name
    $NewServiceMap.Value  = $a.Protocol + '/' + $a.DestinationPort
    $ServiceMaps         += $NewServiceMap
}

$AddressMaps = @()

foreach ($a in $AddressGroups) {
    $NewAddressMap       = "" | Select Name,Value
    $NewAddressMap.Name  = $a.Name
    $NewAddressMap.Value = Resolve-PaAddressGroup $a.Name $AddressGroups $Addresses
    $AddressMaps += $NewAddressMap
}

foreach ($a in $Addresses) {
    $NewAddressMap = "" | Select Name,Value
    $NewAddressMap.Name = $a.Name
    $NewAddressMap.Value = $a.Address
    $AddressMaps += $NewAddressMap
}

#############################################################################################

$NewRules = @()
