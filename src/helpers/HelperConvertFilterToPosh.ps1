function HelperConvertFilterToPosh {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$True,Position=0)]
		[string]$Filter,

        [Parameter(Mandatory=$True,Position=1)]
        [string]$VariableName,

        [Parameter(Mandatory=$True,Position=2)]
        [string]$Property
    )

    $FilterSplit = $Filter.Split()

    $MatchString = "`$$VariableName | ? { "
    foreach ($f in $FilterSplit) {
        switch ($f) {
            { $_ -match '^(and|or)$' } { $MatchString += " -$f " }
                               default { $MatchString += "( `$_.$Property -contains $f )" }
        }
    }
    $MatchString += " }"

    return $MatchString
}