function Get-PaKerberosServerProfile {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name
    )

    $InfoObject   = New-Object PowerAlto.KerberosServerProfile
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'kerberos'

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
        $ResponseObject = New-Object PowerAlto.KerberosServerProfile
        
        $ResponseObject.Name   = $r.name
        $ResponseObject.Realm  = $r.realm
        $ResponseObject.Domain = $r.domain
        
        foreach ($Server in $r.server.entry) {
            $KerberosServer          = New-Object PowerAlto.KerberosServer
            $KerberosServer.Name     = $Server.name
            $KerberosServer.Host     = $Server.host
            if ($Server.port) {
                $KerberosServer.Port     = $Server.port
            }
            $ResponseObject.Servers += $KerberosServer
        }
        
        $ResponseTable += $ResponseObject
    }
    
    return $ResponseTable
}

<#
    public string Name;
	public bool AdminUseOnly;
	public string Realm;
	public string Domain;
	public List<KerberosServer> Servers;
    #>