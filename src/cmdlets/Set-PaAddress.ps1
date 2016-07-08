function Set-PaAddress {
    [CmdletBinding()]
    Param (
        [Parameter(ParameterSetName='Object',Mandatory=$True,ValueFromPipeline=$True)]
        [PowerAlto.AddressObject]$AddressObject,

        [Parameter(Mandatory=$false)]
        [switch]$NoValidation,

        [Parameter(Mandatory=$false)]
        [switch]$Force
    )

    $Action = "set"
    $Xpath  = HelperCreateXpath address

    if ($NoValidation) {
        $ResponseData = Set-PaConfig -Xpath $Xpath -Action $Action -Element $SecurityRule.PrintPlainXml()
    } else {
        $Rules     = Get-PaSecurityRule
        $Tags      = Get-PaTag
        $Zones     = Get-PaZone
        $Addresses = Get-PaAddressObject

        # Check for rules with this name
        $RuleLookup = $Rules | ? { $_.Name -eq $SecurityRule.Name }
        if ($RuleLookup -and !($Force)) {
            Write-Verbose "Checking for existing Security Policy with Name $($SecurityRule.Name)"
            Throw "Security Policy with the name $($SecurityRule.Name) already exists, use -Force to overwrite"
        }

        # Check for Tags
        foreach ($t in $SecurityRule.Tags) {
            Write-Verbose "Checking for tag `"$t`""
            $TagLookup = $Tags | ? { $_.Name -eq $t }
            if (!($TagLookup)) {
                Throw "Tag `"$t`" does not exist."
            }
        }

        # Check for Zones
        foreach ($z in $SecurityRule.SourceZone) {
            Write-Verbose "Checking for Source Zone `"$z`""
            $ZoneLookup = $Zones | ? { $_.Name -eq $z }
            if (!($ZoneLookup)) {
                Throw "Source Zone `"$z`" does not exist."
            }
        }

        foreach ($z in $SecurityRule.DestinationZone) {
            Write-Verbose "Checking for Destination Zone `"$z`""
            $ZoneLookup = $Zones | ? { $_.Name -eq $z }
            if (!($ZoneLookup)) {
                Throw "Destination Zone `"$z`" does not exist."
            }
        }

        # Check for Addresses
        $IpRx = [regex] '(\d+\.){3}\d+(\/\d+)?'
        foreach ($a in $SecurityRule.SourceAddress) {
            $IpMatch = $IpRx.Match($a)
            if (!($IpMatch.Success) -and ($a -ne 'any')) {
                Write-Verbose "Checking for Source Address `"$a`""
                $AddressLookup = $Addresses | ? { $_.name -eq $a }
                if (!($AddressLookup)) {
                    Throw "Source Address `"$a`" does not exist."
                }
            }
        }

        foreach ($a in $SecurityRule.DestinationAddress) {
            $IpMatch = $IpRx.Match($a)
            if (!($IpMatch.Success) -and ($a -ne 'any')) {
                Write-Verbose "Checking for Destination Address `"$a`""
                $AddressLookup = $Addresses | ? { $_.name -eq $a }
                if (!($AddressLookup)) {
                    Throw "Destination Address `"$a`" does not exist."
                }
            }
        }

        $ResponseData = Set-PaConfig -Xpath $Xpath -Action $Action -Element $SecurityRule.PrintPlainXml()
    }

    return $ResponseData
}
