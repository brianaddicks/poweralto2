function Get-PaNatPolicy {
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $InfoObject   = New-Object PowerAlto.NatPolicy
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'rules'

    if ($Name) { $Xpath += "/entry[@name='$Name']" }
    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName.entry } `
                                else { $ResponseData = $ResponseData.entry         }

    $ResponseTable = @()

    foreach ($r in $ResponseData) {
        $ResponseObject = New-Object PowerAlto.NatPolicy
        Write-Verbose "Creating new NatPolicy"
        
        $ResponseObject.Name        = $r.name
        $ResponseObject.Tags        = HelperGetPropertyMembers $r tag
        $ResponseObject.Description = $r.description
        $ResponseObject.NatType     = $r.'nat-type'

        $ResponseObject.SourceZone           = HelperGetPropertyMembers $r from
        $ResponseObject.DestinationZone      = HelperGetPropertyMembers $r to
        $ResponseObject.Service              = $r.service
        $ResponseObject.DestinationInterface = $r.'to-interface'
        $ResponseObject.SourceAddress        = HelperGetPropertyMembers $r source
        $ResponseObject.DestinationAddress   = HelperGetPropertyMembers $r destination

        $SourceTranslation = $r.'source-translation'
        if ($SourceTranslation.'static-ip') {
            $ResponseObject.SourceTranslationType = "StaticIp"

            if ($SourceTranslation.'static-ip'.'bi-directional' -eq 'yes') {
                $ResponseObject.IsBidirectional = $true
            } else {
                $ResponseObject.IsBidirectional = $false
            }

            if ($SourceTranslation.'static-ip'.'translated-address') {
                $ResponseObject.SourceTranslatedAddressType = "TranslatedAddress"
                $ResponseObject.SourceTranslatedAddress = $SourceTranslation.'static-ip'.'translated-address'
            }
        } elseif ($SourceTranslation.'dynamic-ip-and-port') {
            $ResponseObject.SourceTranslationType = 'DynamicIpAndPort'
            if ($SourceTranslation.'dynamic-ip-and-port'.'interface-address') {
                $ResponseObject.SourceTranslatedAddressType = 'InterfaceAddress'
                $ResponseObject.SourceTranslatedInterface = $SourceTranslation.'dynamic-ip-and-port'.'interface-address'.interface
                $ResponseObject.SourceTranslatedAddress = $SourceTranslation.'dynamic-ip-and-port'.'interface-address'.ip
            }
        }

        $ResponseTable += $ResponseObject

        <#
        DestinationAddressTranslation :
        DestinationTranslatedPort     :
        #>

    }
    return $ResponseTable

}
