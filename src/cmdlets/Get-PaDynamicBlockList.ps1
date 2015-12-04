function Get-PaDynamicBlockList {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name
    )

    $InfoObject   = New-Object PowerAlto.DynamicBlockList
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'external-list'

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
        $ResponseObject = New-Object PowerAlto.DynamicBlockList
        
        $ResponseObject.Name        = $r.name
        $ResponseObject.Description = $r.description
        $ResponseObject.Source      = $r.url
        

        $ResponseTable += $ResponseObject
    }
    
    return $ResponseTable
}