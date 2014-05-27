$ScriptPath = Split-Path $($MyInvocation.MyCommand).Path
#$ScriptPath = Split-Path $ScriptPath

$SourceDirectory = "src"
$SourcePath      = $ScriptPath + "\" + $SourceDirectory
$CmdletPath      = $SourcePath + "\" + "cmdlets"
$HelperPath      = $SourcePath + "\" + "helpers"
$CsPath          = $SourcePath + "\" + "cs"
$OutputFile      = $ScriptPath + "\" + "poweralto2.psm1"

$CSharpAssemblies = @(
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Web")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq")).Location
	)

$NeededTypes = @("System.Management.Automation")

$CSharpHeader = @'
###############################################################################
## Custom Objects Create in C-Sharp
###############################################################################


'@

$CmdletHeader = @'
###############################################################################
## Start Powershell Cmdlets
###############################################################################


'@

$HelperFunctionHeader = @'
###############################################################################
## Start Helper Functions
###############################################################################


'@

$Footer = @'
###############################################################################
## Export Cmdlets
###############################################################################

Export-ModuleMember *-*
'@

$FunctionHeader = @'
###############################################################################
# 
'@

###############################################################################
# Start Output

$Output  = ""

###############################################################################
# Add C-Sharp

$Output += $CSharpHeader

$c = 0
foreach ($l in $(ls $CsPath)) {
    $Contents      = [System.IO.File]::ReadAllText($l.FullName)
    $DllPath       = $ScriptPath + '\helper.dll'
    $Output       += $FunctionHeader
    $Output       += $l.BaseName
    $Output       += "`r`n`r`n"
    
    if ($c -eq 0) {
        $Output += @"
Add-Type -ReferencedAssemblies @(
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Web")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq")).Location
	) -OutputAssembly $DllPath -OutputType Library -TypeDefinition @'
$Contents
'@

[System.Reflection.Assembly]::LoadFile("$DllPath")
"@
        $Output += "`r`n`r`n"
    } else {
        $Output += @"
Add-Type -ReferencedAssemblies @(
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Web")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq")).Location,
    "$DllPath"
	) -TypeDefinition @'
$Contents
'@
"@
        $Output += "`r`n`r`n"
    }
    $c++
}

###############################################################################
# Add Cmdlets

$Output += $CmdletHeader

foreach ($l in $(ls $CmdletPath)) {
    $Contents  = gc $l.FullName
    $Output   += $FunctionHeader
    $Output   += $l.BaseName
    $Output   += "`r`n`r`n"
    $Output   += [string]::join("`n",$Contents)
    $Output   += "`r`n`r`n"
}


###############################################################################
# Add Helpers

$Output += $HelperFunctionHeader

foreach ($l in $(ls $HelperPath)) {
    $Contents  = gc $l.FullName
    $Output   += $FunctionHeader
    $Output   += $l.BaseName
    $Output   += "`r`n`r`n"
    $Output   += [string]::join("`n",$Contents)
    $Output   += "`r`n`r`n"
}

###############################################################################
# Add Footer

$Output += $Footer

###############################################################################
# Output File

$Output | Out-File $OutputFile -Force