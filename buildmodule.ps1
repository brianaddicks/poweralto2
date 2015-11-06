[CmdletBinding()]
Param (
    [Parameter(Mandatory=$False,Position=0)]
	[switch]$PushToStrap
)

function ZipFiles {
    [CmdletBinding()]
    Param (
    	[Parameter(Mandatory=$True,Position=0)]
		[string]$ZipFilePath,

        [Parameter(ParameterSetName="Directory",Mandatory=$True,Position=1)]
        [string]$SourceDir,

        [Parameter(ParameterSetName="Files",Mandatory=$True,Position=1)]
        [Array]$SourceFiles,

        [Parameter(Mandatory=$False)]
        [switch]$Force

    )
    Add-Type -Assembly System.IO.Compression.FileSystem
    $CompressionLevel = [System.IO.Compression.CompressionLevel]::Optimal

    if (Test-Path $ZipFilePath) {
        if ($Force) {
            $Delete = Remove-Item $ZipFilePath
        } else {
            Throw "$ZipFilePath exists, use -Force to replace"
        }
    }

    if ($SourceFiles) {
        $TempZipFolder = 'newzip'
        $TempZipFullPath = "$($env:temp)\$TempZipFolder"
        $CreateFolder = New-Item -Path $env:temp -Name $TempZipFolder -ItemType Directory
        $Copy = Copy-Item $SourceFiles -Destination $TempZipFullPath
        $SourceDir = $TempZipFullPath
    }

    [System.IO.Compression.ZipFile]::CreateFromDirectory($SourceDir,$ZipFilePath, $CompressionLevel, $false)

    $Cleanup = Remove-Item $TempZipFullPath -Recurse
}


$ScriptPath = Split-Path $($MyInvocation.MyCommand).Path

$SourceDirectory = "src"
$SourcePath      = $ScriptPath + "\" + $SourceDirectory
$CmdletPath      = $SourcePath + "\" + "cmdlets"
$HelperPath      = $SourcePath + "\" + "helpers"
$CsPath          = $SourcePath + "\" + "cs"
$OutputFile      = $ScriptPath + "\" + "PowerAlto2.psm1"
$ManifestFile    = $ScriptPath + "\" + "PowerAlto2.psd1"
$DllFile         = $ScriptPath + "\" + "PowerAlto2.dll"
$CsOutputFile    = $ScriptPath + "\" + "PowerAlto2.cs"

###############################################################################
# Create Manifest
$ManifestParams = @{ Path = $ManifestFile
                     ModuleVersion = '2.0'
                     RequiredAssemblies = @('PowerAlto2.dll','System.Web')
                     Author             = 'Brian Addicks'
                     RootModule         = 'PowerAlto2.psm1'
                     PowerShellVersion  = '4.0'
                     TypesToProcess     = @('poweralto.types.ps1xml')
                     FormatsToProcess   = @('poweralto.format.ps1xml') }

New-ModuleManifest @ManifestParams

###############################################################################
# 

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

$CsOutput  = ""

###############################################################################
# Add C-Sharp

$AssemblyRx       = [regex] '^using\ .+?;'
$NameSpaceStartRx = [regex] 'namespace PowerAlto {'
$NameSpaceStopRx  = [regex] '^}$'

$Assemblies    = @()
$CSharpContent = @()

$c = 0
foreach ($f in $(ls $CsPath)) {
    foreach ($l in (gc $f.FullName)) {
        $AssemblyMatch       = $AssemblyRx.Match($l)
        $NameSpaceStartMatch = $NameSpaceStartRx.Match($l)
        $NameSpaceStopMatch  = $NameSpaceStopRx.Match($l)

        if ($AssemblyMatch.Success) {
            $Assemblies += $l
            continue
        }

        if ($NameSpaceStartMatch.Success) {
            $AddContent = $true
            continue
        }

        if ($NameSpaceStopMatch.Success) {
            $AddContent = $false
            continue
        }

        if ($AddContent) {
            $CSharpContent += $l
        }
    }
}

#$Assemblies | Select -Unique | sort -Descending

$CSharpOutput  = $Assemblies | Select -Unique | sort -Descending
$CSharpOutput += 'namespace PowerAlto {'
$CSharpOutput += $CSharpContent
$CSharpOutput += '}'

$CsOutput += [string]::join("`n",$CSharpOutput)
#$CsOutput | Out-File $CsOutputFile -Force


Add-Type -ReferencedAssemblies @(
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Web")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq")).Location
	) -OutputAssembly $DllFile -OutputType Library -TypeDefinition $CsOutput

###############################################################################
# Add Cmdlets

$Output = $CmdletHeader

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

if ($PushToStrap) {
    $FilesToZip = ls "$PSScriptRoot\poweralto*" -Exclude *.zip
    $CreateZip = ZipFiles -ZipFilePath "$PSScriptRoot\poweralto2.zip" -SourceFiles $FilesToZip -Force
    $StageFolder = '\\vmware-host\Shared Folders\Dropbox\strap\stages\poweralto2\'
    $Copy = Copy-Item "$PSScriptRoot\poweralto2.zip" $StageFolder -Force
}

#cp C:\dev\poweralto2\PowerAlto2.psm1 \\athena2\c$\_strap\poweralto2
#cp C:\dev\poweralto2\PowerAlto2.cs \\athena2\c$\_strap\poweralto2
#cp C:\dev\poweralto2\PowerAlto2.dll \\athena2\c$\_strap\poweralto2
#cp C:\dev\poweralto2\PowerAlto2.psd1 \\athena2\c$\_strap\poweralto2