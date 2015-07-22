function Get-PaLicense {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False)]
        [switch]$Fetch,

        [Parameter(Mandatory=$False)]
        [switch]$Quiet

    )

    $Command = "<request><license><fetch></fetch></license></request>"

    $ResponseData = Invoke-PaOperation $Command

    if ($Quiet) {
        return $true
    } else {
        return $ResponseData.licenses.entry
    }
}
