function HelperCheckPaError {
	Param (
	    [Parameter(Mandatory=$True,Position=0)]
	    $Response
    )

    $Status = $Response.data.response.status
    if ($Status -eq "error") {
        if ($Response.data.response.msg.line) { $ErrorMessage = $Response.data.response.msg.line } `
                                         else { $ErrorMessage = $Response.data.response.msg      }
        Throw "$ErrorMessage`."
    } else {
        return $Response.data.response.result
    }
}
