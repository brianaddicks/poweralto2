function HelperCheckPaError {
    [CmdletBinding()]
	Param (
	    [Parameter(Mandatory=$True,Position=0)]
	    $Response
    )

    $Status = $Response.data.response.status
    Write-Verbose $Status

    if ($Response.data.response.result.error) {
        $ErrorMessage = $Response.data.response.result.error
    }

    if ($Status -eq "error") {
        if ($Response.data.response.code) {
            $ErrorMessage  = "Error Code $($Response.data.response.code): "
            $ErrorMessage += $Response.data.response.result.msg
        } elseif ($Response.data.response.msg.line) {
            Write-Verbose "Line is: $($Response.data.response.msg.line)"
            $ErrorMessage = $Response.data.response.msg.line
        } elseif ($Response.error) {
            $ErrorMessage = $Response.error
        } else {
            Write-Verbose "Message: $($Response.data.response.msg.line)"
            $ErrorMessage = $Response.data.response.msg
        }
    }
    if ($ErrorMessage) {
        Throw "$ErrorMessage`."
    } else {
        return $Response.data.response.result
    }
}
