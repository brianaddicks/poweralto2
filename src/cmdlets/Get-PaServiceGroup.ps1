function Get-PaServiceGroup {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $InfoObject   = New-Object PowerAlto.ServiceGroup
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'service-group'

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
        $ResponseObject = New-Object PowerAlto.ServiceGroup
        Write-Verbose "Creating new ServiceGroup"
        
        $ResponseObject.Name = $r.name
        Write-Verbose "Setting ServiceGroup Name $($r.name)"
        
        
        
        $ResponseObject.Members = HelperGetPropertyMembers $r members

        $ResponseObject.Tags = HelperGetPropertyMembers $r tag

        $ResponseTable += $ResponseObject
        Write-Verbose "Adding object to array"
    }
    
    return $ResponseTable
}