function Invoke-PaOperation {
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Command
    )

    HelperCheckPaConnection

    $QueryTable = @{ type = "op"
                     cmd  = $Command }
    
    $QueryString = HelperCreateQueryString $QueryTable
    $Url         = $global:PaDeviceObject.UrlBuilder($QueryString)
    $Response    = $global:PaDeviceObject.HttpQuery($url)

    return HelperCheckPaError $Response
}