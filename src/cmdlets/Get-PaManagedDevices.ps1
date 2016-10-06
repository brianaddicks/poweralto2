function Get-PaManagedDevices {
    [CmdletBinding()]
    Param (
    )

    $Command = "<show><devices><all></all></devices></show>"

    $ResponseData = Invoke-PaOperation $Command

    $ResponseTable = @()

    foreach ($r in $ResponseData.devices.entry) {
        $ResponseObject = New-Object PowerAlto.PaDevice

        $ResponseObject.Name            = $r.hostname
		$ResponseObject.IpAddress       = $r.'ip-address'
        $ResponseObject.Model           = $r.model
        $ResponseObject.Serial          = $r.serial
        $ResponseObject.OsVersion       = $r.'sw-version'
        $ResponseObject.GpAgent         = $r.'global-protect-client-package-version'
        $ResponseObject.AppVersion      = $r.'app-version'
        $ResponseObject.ThreatVersion   = $r.'threat-version'
        $ResponseObject.WildFireVersion = $r.'wildfire-version'
        $ResponseObject.UrlVersion      = $r.'url-filtering-version'

        $ResponseTable                += $ResponseObject
    }

    return $ResponseTable
}