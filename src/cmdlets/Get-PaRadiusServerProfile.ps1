function Get-PaRadiusServerProfile {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name
    )

	$VerbosePrefix = "Get-PaRadiusServerProfile:"
    $InfoObject    = New-Object PowerAlto.RadiusServerProfile
    $Xpath         = $InfoObject.BaseXPath
    $RootNodeName  = 'radius'

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
        $ResponseObject = New-Object PowerAlto.RadiusServerProfile
        
        $ResponseObject.Name   = $r.name
        $ResponseObject.Domain = $r.domain
        
        foreach ($Server in $r.server.entry) {
            $NewServer          = New-Object PowerAlto.RadiusServer
            $NewServer.Name     = $Server.name
            $NewServer.Host     = $Server."ip-address"
			$NewServer.Secret   = $Server.secret
            if ($Server.port) {
                $NewServer.Port     = $Server.port
            }
            $ResponseObject.Servers += $NewServer
        }
        
        $ResponseTable += $ResponseObject
    }
    
    return $ResponseTable
}