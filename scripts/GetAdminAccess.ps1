[CmdletBinding()]
Param (
	[Parameter(Mandatory=$True,ParameterSetName="Secret",Position=0)]
	[ValidateScript({Test-Path $_})]
	[string]$SecretFile,
	
	[Parameter(Mandatory=$True,ParameterSetName="creds",Position=0)]
	[string]$Device,
	
	[Parameter(Mandatory=$True,ParameterSetName="creds",Position=1)]
	[PScredential]$Credential,
	
	[Parameter(Mandatory=$False)]
	[ValidateScript({Test-Path $_})]
	[string]$OutputDir,
	
	[Parameter(Mandatory=$False)]
	[switch]$CombineToXlsx
)

#################################################################################
# Excel Helper
function HelperCombineCsvToExcel {
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$True,Position=0)]
		[Array]$Csvs,
		
		[Parameter(Mandatory=$True,Position=1)]
		[string]$OutputFile,
		
		[Parameter(Mandatory=$False)]
		[switch]$OverWrite
	)
	
	if (Test-Path $OutputFile) {
		if ($OverWrite) {
			try {
				rm $OutputFile -Force -ErrorAction Stop
			} catch {
				Throw "Cannot Remove $OutputFile"
			}
		} else {
			Throw "File exists at $OutputFile. Use -OverWrite to replace it"
		}
	}

	$excelapp = new-object -comobject Excel.Application
	$excelapp.sheetsInNewWorkbook = $csvs.Count
	$xlsx = $excelapp.Workbooks.Add()
	$sheet=1
	
	foreach ($Csv in $csvs) {
		$FileInfo = ls $Csv
		Write-Verbose $FileInfo.FullName
		Write-Verbose $FileInfo.Name
		$row=1
		$column=1
		$worksheet      = $xlsx.Worksheets.Item($sheet)
		$worksheet.Name = $FileInfo.Name
		$file           = Import-Csv $csv
		
		# Get the Headers, in the order they were presented
		$Properties = $file[0].psobject.Properties.name
		foreach ($p in $Properties) {
				$worksheet.Cells.Item($row,$column) = $p
				$column++
		}
		$column = 1
		$row++
		
		foreach($line in $file) {
			foreach ($p in $Properties) {
				#Write-Verbose "adding $($line.$p)"
				$worksheet.Cells.Item($row,$column) = $line.$p
				$column++
			}
			$column=1
			$row++
		}
		Write-Verbose "AutoFit Rows"
		$AutoFit = $Worksheet.UsedRange.EntireRow.Autofit()
		Write-Verbose "AutoFit Columns"
		$AutoFit = $Worksheet.UsedRange.EntireColumn.Autofit()
		$sheet++
	}
	
	Write-Verbose "Saving workbook $OutputFile"
	$xlsx.SaveAs($OutputFile)
	Write-Verbose "Exiting excel"
	$excelapp.quit()
}

#################################################################################



if ($SecretFile) {
	$DeviceConnectionDetails = gc $SecretFile | ConvertFrom-Json
	$Device  = $DeviceConnectionDetails.IpAddress
	$ApiKey  = $DeviceConnectionDetails.ApiKey
	$Connect = Get-PaDevice -Device $Device -ApiKey $ApiKey
} else {
	$Connect = Get-PaDevice -Device $Device -PaCred $Credential
}

$DefaultSnmpCommunity = "public"
$DefaultAdminAccounts = @("admin")
$LatestOsVersion      = "7.0.3"

$IpMaskRx = [regex] '^(\d+\.){3}\d+\/\d{1,2}$'
$IpRx     = [regex] '^(\d+\.){3}\d+$'

$Version = $Global:PaDeviceObject.OsVersion

$Admins       = Get-PaAdministrator
$AuthProfiles = Get-PaAuthenticationProfile

$RadiusProfiles   = Get-PaRadiusServerProfile
$KerberosProfiles = Get-PaKerberosServerProfile
$LdapProfiles     = Get-PaLdapServerProfile



$AdminOutput = @()
foreach ($Admin in $Admins) {
	$NewObject = "" | Select Name,Role,AuthType,AuthProfile,PasswordProfile,IsDefault
	$AdminOutput += $NewObject
	
	if ($DefaultAdminAccounts -contains $Admin.Name) { $NewObject.IsDefault = $True  } `
	                                            else { $NewObject.IsDefault = $false }
	
	$NewObject.Name = $Admin.Name
	$NewObject.Role = $Admin.Role
	
	if ($Admin.AuthenticationProfile) {
		$NewObject.AuthProfile     = $Admin.AuthenticationProfile
		$NewObject.PasswordProfile = "EXTERNAL"
		$Lookup = $AuthProfiles | ? { $_.Name -eq $NewObject.AuthProfile }
		
		if ($Lookup) {
			$NewObject.AuthType = $Lookup.Method
		} else {
			$NewObject.AuthType = "PROFILE NOT FOUND"
		}
	} else {
		$NewObject.AuthType        = "local"
		$NewObject.AuthProfile     = "n/a"
		if ($Admin.PasswordProfile) {
			$NewObject.PasswordProfile = $Admin.PasswordProfile
		} else {
			$NewObject.PasswordProfile = "none"
		}
	}
}


$SnmpSettings = Get-PaSnmpSettings
if ($DefaultSnmpCommunity -eq $SnmpSettings) {
	$SnmpSettings = $SnmpSettings | Select Location,Contact,EventSpecificTraps,Version,Community,@{n="IsDefault";e={$true}}
} else {
	$SnmpSettings = $SnmpSettings | Select Location,Contact,EventSpecificTraps,Version,Community,@{n="IsDefault";e={$false}}
}

$AuthProfileOutput = @()
$AdminAuthProfiles  = $AdminOutput | ? { $_.Authprofile -ne "n/a" } | select AuthType,AuthProfile -Unique
foreach ($AuthProfile in $AdminAuthProfiles) {
	switch ($Authprofile.AuthType) {
		kerberos {
			$Lookup = $AuthProfiles | ? { ($_.Method -eq $AuthProfile.AuthType) -and ($_.Name -eq $AuthProfile.AuthProfile) }
			Write-Verbose $Lookup.Name
			$ServerProfile = $KerberosProfiles | ? { $_.Name -eq $Lookup.ServerProfile }
			$AuthProfileOutput += $ServerProfile | Select @{N="AuthProfile";E={$AuthProfile.AuthProfile}},
													      @{N="Type";E={$AuthProfile.AuthType}},
			                                              @{N="ServerProfile";E={$_.Name}},
														  Realm,
														  Domain,
														  @{ N="Servers";E={ $_.Servers.Host -join "`r`n" }}
		}
		radius {
			$Lookup = $AuthProfiles | ? { ($_.Method -eq $AuthProfile.AuthType) -and ($_.Name -eq $AuthProfile.AuthProfile) }
			Write-Verbose $Lookup.Name
			$ServerProfile = $RadiusProfiles | ? { $_.Name -eq $Lookup.ServerProfile }
			$AuthProfileOutput += $ServerProfile | Select @{N="AuthProfile";E={$AuthProfile.AuthProfile}},
													      @{N="Type";E={$AuthProfile.AuthType}},
			                                              @{N="ServerProfile";E={$_.Name}},
														  Realm,
														  Domain,
														  @{ N="Servers";E={ $_.Servers.Host -join "`r`n" }}
		}
		ldap {
			$Lookup = $AuthProfiles | ? { ($_.Method -eq $AuthProfile.AuthType) -and ($_.Name -eq $AuthProfile.AuthProfile) }
			Write-Verbose $Lookup.Name
			$ServerProfile = $LdapProfiles | ? { $_.Name -eq $Lookup.ServerProfile }
			$AuthProfileOutput += $ServerProfile | Select @{N="AuthProfile";E={$AuthProfile.AuthProfile}},
													      @{N="Type";E={$AuthProfile.AuthType}},
			                                              @{N="ServerProfile";E={$_.Name}},
														  Realm,
														  Domain,
														  @{ N="Servers";E={ $_.Servers.Host -join "`r`n" }}
		}
		default {
			Write-Verbose "Couldn't switch: $($Authprofile.AuthType)"
		}
	}	
}

#############################################################
# Management methods/acl

$ManagementMethod       = Get-PaManagementServices
$ManagementPermittedIps = Get-PaManagementAcl
$ManagementTimeout      = Get-PaAdminIdleTimeout

$ManagementOutput = @()
$Properties = $ManagementMethod.psobject.Properties.name | ? { $_ -notmatch "xpath" }
foreach ($Property in $Properties) {
	$NewObject         = "" | Select Name,Value
	$NewObject.Name    = "$Property`:"
	$NewObject.Value   = $ManagementMethod.$Property
	$ManagementOutput += $NewObject
}

$NewObject         = "" | Select Name,Value
$NewObject.Name    = "PermittedIps:"
$NewObject.Value   = $ManagementPermittedIps -join "`r`n"
$ManagementOutput += $NewObject

$NewObject         = "" | Select Name,Value
$NewObject.Name    = "Admin Idle Timeout:"
$NewObject.Value   = $ManagementTimeout
$ManagementOutput += $NewObject

$NewObject         = "" | Select Name,Value
$NewObject.Name    = "Installed Version:"
$NewObject.Value   = $Version
$ManagementOutput += $NewObject

$NewObject         = "" | Select Name,Value
$NewObject.Name    = "Latest Available Version:"
$NewObject.Value   = $LatestOsVersion
$ManagementOutput += $NewObject

#############################################################
# Logging

$Logging  = @()
$Logging += Get-PaSystemLogSettings
$Logging += Get-PaConfigLogSettings


#############################################################
# Output

if ($OutputDir) {
	$AdminOutput       | Export-Csv "$OutputDir\AdminAccounts.csv"     -NoTypeInformation
	$SnmpSettings      | Export-Csv "$OutputDir\SnmpSettings.csv"      -NoTypeInformation
	$AuthProfileOutput | Export-Csv "$OutputDir\Authprofiles.csv"      -NoTypeInformation
	$ManagementOutput  | Export-Csv "$OutputDir\ManagementMethods.csv" -NoTypeInformation
	$Logging           | Export-Csv "$OutputDir\Logging.csv" -NoTypeInformation
	if ($CombineToXlsx) {
		$Csvs = @()
		$Csvs += "$OutputDir\AdminAccounts.csv"
		$Csvs += "$OutputDir\SnmpSettings.csv"
		$Csvs += "$OutputDir\Authprofiles.csv"
		$Csvs += "$OutputDir\ManagementMethods.csv"
		$Csvs += "$OutputDir\Logging.csv"
			
		HelperCombineCsvToExcel $Csvs "$OutputDir\Firewall-Findings.xlsx" -OverWrite
	}
}

