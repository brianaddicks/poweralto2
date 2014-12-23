function Get-PaTag {
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $PaObject = New-Object PowerAlto.Tag
    $Xpath    = $PaObject.XPath

    if ($Name) { $Xpath += "/entry[@name='$Name']" }

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    
    $ConfigData = Get-PaConfig -Xpath $Xpath -Action $Action

    return $ConfigData

}
