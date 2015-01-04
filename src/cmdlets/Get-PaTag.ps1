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

    if ($ConfigData.tag) { $ConfigData = $ConfigData.tag }

    $ColorCodes = @{"red"         = "color1"
                    "green"       = "color2"
                    "blue"        = "color3"
                    "yellow"      = "color4"
                    "copper"      = "color5"
                    "orange"      = "color6"
                    "purple"      = "color7"
                    "gray"        = "color8"
                    "light green" = "color9"
                    "cyan"        = "color10"
                    "light gray"  = "color11"
                    "blue gray"   = "color12"
                    "lime"        = "color13"
                    "black"       = "color14"
                    "gold"        = "color15"
                    "brown"       = "color16" }

    $ColorCodesEnum = $ColorCodes.GetEnumerator()

    $ReturnObject = @()
    foreach ($c in $ConfigData.entry) {
        $NewPaObject           = New-Object PowerAlto.Tag
        $ReturnObject         += $NewPaObject
        $NewPaObject.Name      = $c.Name
        $NewPaObject.Comments  = $c.Comments

        if ($c.Color) {
            $Color = $ColorCodesEnum | ? { $_.Value -eq $c.Color }
            $NewPaObject.Color = $Color.Name
        }

    }

    return $ReturnObject

}
