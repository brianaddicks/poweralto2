function Get-PaLicense {
    [CmdletBinding()]
    Param (
    )

    $Command = "<request><license><fetch></fetch></license></request>"

    $ResponseData = Invoke-PaOperation $Command
    $ResponseTable = @()

    foreach ($r in $ResponseData.licenses.entry) {
        $ResponseObject = New-Object PowerAlto.License

        $ResponseObject.Feature     = $r.feature
        $ResponseObject.Description = $r.description
        $ResponseObject.DateIssued  = $r.issued
        $ResponseObject.DateExpires = $r.expires
        $ResponseObject.AuthCode    = $r.authcode

        $ResponseTable                += $ResponseObject
    }

    $Command = "<request><support><check></check></support></request>"
    $ResponseData = Invoke-PaOperation $Command
    
    $ResponseObject = New-Object PowerAlto.License

    $ResponseObject.Feature     = $ResponseData.SupportInfoResponse.Support.SupportLevel
    $ResponseObject.Description = $ResponseData.SupportInfoResponse.Support.SupportDescription
    $ResponseObject.DateExpires = $ResponseData.SupportInfoResponse.Support.ExpiryDate

    $ResponseTable += $ResponseObject

    return $ResponseTable
}
