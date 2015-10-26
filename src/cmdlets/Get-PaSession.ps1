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

    $ReturnObject = $False
    
    
    
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
                     "rematch"           = "security-policy"
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
    
    
    <#
    if ($Application)       { $FilterString += "<application>"       + "$Application"       + "</application>"       }
    if ($Destination)       { $FilterString += "<destination>"       + "$Destination"       + "</destination>"       }
    if ($DestinationPort)   { $FilterString += "<destination-port>"  + "$DestinationPort"   + "</destination-port>"  }
    if ($DestinationUser)   { $FilterString += "<destination-user>"  + "$DestinationUser"   + "</destination-user>"  }
    if ($EgressInterface)   { $FilterString += "<egress-interface>"  + "$EgressInterface"   + "</egress-interface>"  }
    if ($SourceZone)        { $FilterString += "<from>"              + "$SourceZone"        + "</from>"              }
    if ($HardwareInterface) { $FilterString += "<hw-interface>"      + "$HardwareInterface" + "</hw-interface>"      }
    if ($IngressInterface)  { $FilterString += "<ingress-interface>" + "$IngressInterface"  + "</ingress-interface>" }
    if ($MinKb)             { $FilterString += "<min-kb>"            + "$MinKb"             + "</min-kb>"            }
    if ($Nat)               { $FilterString += "<nat>"               + "$Nat"               + "</nat>"               }
    if ($NatRule)           { $FilterString += "<nat-rule>"          + "$NatRule"           + "</nat-rule>"          }
    if ($PbfRule)           { $FilterString += "<pbf-rule>"          + "$PbfRule"           + "</pbf-rule>"          }
    if ($Protocol)          { $FilterString += "<protocol>"          + "$Protocol"          + "</protocol>"          }
    if ($QosClass)          { $FilterString += "<qos-class>"         + "$QosClass"          + "</qos-class>"         }
    if ($QosNodeId)         { $FilterString += "<qos-node-id>"       + "$QosNodeId"         + "</qos-node-id>"       }
    if ($QosRule)           { $FilterString += "<qos-rule>"          + "$QosRule"           + "</qos-rule>"          }
    if ($Rematch)           { $FilterString += "<rematch>"           + "security-policy"    + "</rematch>"           }
    if ($SecurityRule)      { $FilterString += "<rule>"              + "$SecurityRule"      + "</rule>"              }
    if ($Source)            { $FilterString += "<source>"            + "$Source"            + "</source>"            }
    if ($SourcePort)        { $FilterString += "<source-port>"       + "$SourcePort"        + "</source-port>"       }
    if ($SourceUser)        { $FilterString += "<source-user>"       + "$SourceUser"        + "</source-user>"       }
    if ($SslDecrypt)        { $FilterString += "<ssl-decrypt>"       + "$SslDecrypt"        + "</ssl-decrypt>"       }
    if ($StartAt)           { $FilterString += "<start-at>"          + "$StartAt"           + "</start-at>"          }
    if ($State)             { $FilterString += "<state>"             + "$State"             + "</state>"             }
    if ($DestinationZone)   { $FilterString += "<to>"                + "$DestinationZone"   + "</to>"                }
    if ($Type)              { $FilterString += "<type>"              + "$Type"              + "</type>"              }
    if ($VsysName)          { $FilterString += "<vsys-name>"         + "$VsysName"          + "</vsys-name>"         }
#>
    if ($Id) {
        $Command = "<show><session><id>$Filter</id></session></show>"
    } elseif ($FilterString -ne "") {
        $Command = "<show><session><all><filter>$FilterString</filter></all></session></show>"
    } else {
        Throw "Must specifiy an Id or a Filter"
    }
	
    $ResponseData = Invoke-PaOperation $Command

    return $ReturnObject
}
