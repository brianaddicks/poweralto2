function Clear-PaSession {
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
        $Command = "<clear><session><id>$Id</id></session></clear>"
    } elseif ($FilterString -ne "") {
        $Command = "<clear><session><all><filter>$FilterString</filter></all></session></clear>"
    } else {
        Throw "Must specifiy an Id or a Filter"
    }
	
    $ResponseData = Invoke-PaOperation $Command
    
    switch ($ResponseData.member) {
        "sessions cleared" {
            $ReturnObject = $true
        }
        default {
            $ReturnObject = $false
        }
    }

    return $ReturnObject
}