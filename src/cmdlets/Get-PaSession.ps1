function Get-PaSession {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,ParameterSetName="Id",Position=0)]
        [int]$Id,
		
        # Filter Fields
		[Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$Application,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$Destination,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [int]$DestinationPort,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$DestinationUser,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$EgressInterface,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$SourceZone,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$HardwareInterface,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$IngressInterface,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$MinKb,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$Nat,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$NatRule,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$PbfRule,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$Protocol,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$QosClass,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$QosNodeId,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$QosRule,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [switch]$Rematch,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$SecurityRule,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$Source,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$SourcePort,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$SourceUser,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$SslDecrypt,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [double]$StartAt,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$State,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$DestinationZone,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$Type,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$VsysName
    )

    $ReturnObject = @()
    
    $FilterString = ""
    
    $FilterHash = @{ "application"       = $Application
                     "destination"       = $Destination
                     "destination-port"  = $DestinationPort
                     "destination-user"  = $DestinationUser
                     "egress-interface"  = $EgressInterface
                     "from"              = $SourceZone
                     "hw-interface"      = $HardwareInterface
                     "ingress-interface" = $IngressInterface
                     "min-kb"            = $MinKb
                     "nat"               = $Nat
                     "nat-rule"          = $NatRule
                     "pbf-rule"          = $PbfRule
                     "protocol"          = $Protocol
                     "qos-class"         = $QosClass
                     "qos-node-id"       = $QosNodeId
                     "qos-rule"          = $QosRule
                     "rule"              = $SecurityRule
                     "source"            = $Source
                     "source-port"       = $SourcePort
                     "source-user"       = $SourceUser
                     "ssl-decrypt"       = $SslDecrypt
                     "start-at"          = $StartAt
                     "state"             = $State
                     "to"                = $DestinationZone
                     "type"              = $Type
                     "vsys-name"         = $VsysName }
    
    if ($Rematch) { $FilterHash += @{ "rematch" = "security-policy" } }
    
    foreach ($Filter in $FilterHash.GetEnumerator()) {
        if ($Filter.Value) {
            $FilterString += "<" + [string]$Filter.Name + ">"
            $FilterString += $Filter.Value
            $FilterString += "</" + [string]$Filter.Name + ">"
        }
    }

    if ($Id) {
        $Command = "<show><session><id>$Id</id></session></show>"
    } elseif ($FilterString -ne "") {
        $Command = "<show><session><all><filter>$FilterString</filter></all></session></show>"
    } else {
        $Command = "<show><session><all></all></session></show>"
        #Throw "Must specifiy an Id or a Filter"
    }
	
    $ResponseData = Invoke-PaOperation $Command
    
    if ($ResponseData.entry) { $ResponseData = $ResponseData.entry } `
                        else { $ResponseData = @($ResponseData)    }
    
    $Global:test = $ResponseData
    
    foreach ($Entry in $ResponseData) {
        Write-verbose "1"
        $global:testentry = $Entry
        $NewObject     = New-Object -TypeName PowerAlto.Session
        $ReturnObject += $NewObject
        
        if ($Id) { $NewObject.Id = $Id } `
            else { $NewObject.Id = $Entry.idx }

        # Interfaces
        if ($NewObject.IngressInterface = $Entry.ingress) {
            $NewObject.IngressInterface = $Entry.ingress
        } else {
            $NewObject.IngressInterface = $Entry.'igr-if'
        }
        
        if ($NewObject.EgressInterface = $Entry.egress) {
            $NewObject.EgressInterface = $Entry.egress
        } else {
            $NewObject.EgressInterface = $Entry.'egr-if'
        }
        
        # Times
        $NewObject.StartTime  = $Entry.'start-time'
        $NewObject.Timeout    = $Entry.timeout
        $NewObject.TimeToLive = $Entry.ttl
            
            
        $NewObject.Application      = $Entry.application
        $NewObject.Vsys             = $Entry.vsys

        if ($NewObject.SecurityRule = $Entry.'security-rule') {
            $NewObject.SecurityRule = $Entry.'security-rule'
        } else {
            $NewObject.SecurityRule = $Entry.rule
        }
            
        # Nat Properties
        if ($Entry.'nat-rule') {
            $NewObject.NatRule = $Entry.'nat-rule'
            $NewObject.Nat     = $true
        } else {
            $NewObject.Nat     = [System.Convert]::ToBoolean($Entry.nat)
        }
        
        if ($Entry.'nat-src') {
            $NewObject.SourceNat            = [System.Convert]::ToBoolean($Entry.'nat-src')
            if ($NewObject.SourceNat) {
                $NewObject.TranslatedSource     = $Entry.s2c.dport
                $NewObject.TranslatedSourcePort = $Entry.s2c.dst
            }
        } else {
            $NewObject.SourceNat            = [System.Convert]::ToBoolean($Entry.srcnat)
            if ($NewObject.SourceNat) {
                $NewObject.TranslatedSource     = $Entry.xsource
                $NewObject.TranslatedSourcePort = $Entry.xsport
            }
        }
                         
        if ($Entry.'nat-dst') {
            $NewObject.DestinationNat            = [System.Convert]::ToBoolean($Entry.'nat-dst')
            if ($NewObject.DestinationNat) {
                $NewObject.TranslatedDestination     = $Entry.c2s.dport
                $NewObject.TranslatedDestinationPort = $Entry.c2s.dst
            }
        } else {
            $NewObject.DestinationNat            = [System.Convert]::ToBoolean($Entry.dstnat)
            if ($NewObject.DestinationNat) {
                $NewObject.TranslatedDestination     = $Entry.xdst
                $NewObject.TranslatedDestinationPort = $Entry.xdport
            }
        }
        
        
        
        
        
        if ($Entry.c2s) {
            $NewObject.Source     = $Entry.c2s.source
            $NewObject.SourcePort = $Entry.c2s.sport
            $NewObject.SourceUser = $Entry.c2s.'src-user'
            
            $NewObject.Destination     = $Entry.c2s.dst
            $NewObject.DestinationPort = $Entry.c2s.dport
            $NewObject.DestinationUser = $Entry.c2s.'dst-user'
            
            $NewObject.Protocol  = $Entry.c2s.proto
            $NewObject.State     = $Entry.c2s.state
            
            $NewObject.SourceZone = $Entry.c2s.'source-zone'
        } else {
            $NewObject.Source     = $Entry.source
            $NewObject.SourceZone = $Entry.from
            $NewObject.SourcePort = $Entry.sport
            
            $NewObject.Destination     = $Entry.dst
            $NewObject.DestinationPort = $Entry.dport
            
            $NewObject.Protocol  = $Entry.proto
            $NewObject.State     = $Entry.state 
        }
        
        if ($Entry.s2c) {
            $NewObject.DestinationZone = $Entry.s2c.'source-zone'
        } else {
            $NewObject.DestinationZone = $Entry.to
        }
    }

    return $ReturnObject
}