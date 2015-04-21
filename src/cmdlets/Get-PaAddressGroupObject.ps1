function Get-PaAddressGroupObject {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $InfoObject   = New-Object PowerAlto.AddressGroupObject
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'address-group'

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
        $ResponseObject = New-Object PowerAlto.AddressGroupObject
        Write-Verbose "Creating new AddressGroupObject"
        
        $ResponseObject.Name = $r.name
        Write-Verbose "Setting Address Group Name $($r.name)"
        
        if ($r.dynamic) {
            $ResponseObject.Type = 'dynamic'
            $ResponseObject.Filter = $r.dynamic.filter.trim()
        }

        if ($r.static) {
            $ResponseObject.Type = 'static'
            $ResponseObject.Members = HelperGetPropertyMembers $r static
        }

        $ResponseObject.Tags = HelperGetPropertyMembers $r tag
        $ResponseObject.Description = $r.description


        $ResponseTable += $ResponseObject
        Write-Verbose "Adding object to array"
    }

    #############################################
    # Lookup dynamic members

    $DynamicGroups = $ResponseTable | ? { $_.Type -eq 'dynamic' }
    if ($DynamicGroups) {
        $Addresses = Get-PaAddressObject
        foreach ($d in $DynamicGroups) {
            $Expression = HelperConvertFilterToPosh $d.Filter Addresses Tags
            Write-Verbose $d.Filter
            Write-Verbose $Expression
            $Members = @(iex $Expression)
            $d.Members = $Members.Name
        }
    }
    
    return $ResponseTable
}