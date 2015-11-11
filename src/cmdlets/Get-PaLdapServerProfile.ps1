function Get-PaLdapServerProfile {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name
    )

    $InfoObject   = New-Object PowerAlto.LdapServerProfile
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'ldap'

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
        $ResponseObject = New-Object PowerAlto.LdapServerProfile
        
        $ResponseObject.Name   = $r.name
        $ResponseObject.Type   = $r.'ldap-type'
        $ResponseObject.BindDn   = $r.'bind-dn'
        $ResponseObject.BindPassword   = $r.'bind-password'
        $ResponseObject.Base   = $r.base
        $ResponseObject.Domain = $r.domain
        
        if ($r.ssl -eq "yes") { $ResponseObject.Ssl = $true }
        
        foreach ($Server in $r.server.entry) {
            $NewServer          = New-Object PowerAlto.LdapServer
            $NewServer.Name     = $Server.name
            $NewServer.Host     = $Server.address
            if ($Server.port) {
                $NewServer.Port     = $Server.port
            }
            $ResponseObject.Servers += $NewServer
        }
        
        $ResponseTable += $ResponseObject
    }
    
    return $ResponseTable
}