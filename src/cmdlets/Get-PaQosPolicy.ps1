function Get-PaQosPolicy {
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $InfoObject   = New-Object PowerAlto.QosPolicy
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
        $ResponseObject = New-Object PowerAlto.QosPolicy
        
        $ResponseObject.Name        = $r.name
        $ResponseObject.Tags        = HelperGetPropertyMembers $r tag
        $ResponseObject.Description = $r.description
        

        $ResponseObject.SourceZone    = HelperGetPropertyMembers $r from
        $ResponseObject.SourceAddress = HelperGetPropertyMembers $r source
        $ResponseObject.SourceUser    = HelperGetPropertyMembers $r source-user
        if ($r.'negate-source' -eq 'yes') {
            $ResponseObject.SourceNegate = $true
        }

        $ResponseObject.DestinationZone      = HelperGetPropertyMembers $r to
        $ResponseObject.DestinationAddress   = HelperGetPropertyMembers $r destination
        if ($r.'negate-destination' -eq 'yes') {
            $ResponseObject.DestinationNegate = $true
        }

        $ResponseObject.UrlCategory = HelperGetPropertyMembers $r category
        $ResponseObject.Application = HelperGetPropertyMembers $r application
        $ResponseObject.Service     = HelperGetPropertyMembers $r service

        $ResponseObject.Class = $r.action.class
        
        $ResponseTable += $ResponseObject

        <#
        Schedule           : none
        #>

    }
    return $ResponseTable

}
