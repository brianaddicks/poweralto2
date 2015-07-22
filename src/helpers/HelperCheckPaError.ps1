function HelperCheckPaError {
    [CmdletBinding()]
	Param (
	    [Parameter(Mandatory=$True,Position=0)]
	    $Response
    )

    $CmdletName = $MyInvocation.MyCommand.Name

    $Status = $Response.data.response.status
    HelperWriteCustomVerbose $CmdletName "Status returned: $Status"

    if ($Response.data.response.result.error) {
        $ErrorMessage = $Response.data.response.result.error
    }

    if ($Status -eq "error") {
        if ($Response.data.response.msg.line -eq "Command succeeded with no output") {
            HelperWriteCustomVerbose $CmdletName $Response.data.response.msg.line
            #placeholder for stupid restart api call
        } elseif ($Response.data.response.code) {
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
