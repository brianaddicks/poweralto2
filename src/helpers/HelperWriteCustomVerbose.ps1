function HelperWriteCustomVerbose {
    [CmdletBinding()]
	Param (
        [Parameter(Mandatory=$True,Position=0)]
	    [string]$Cmdlet,

	    [Parameter(Mandatory=$True,Position=1)]
	    [string]$Message
    )
    Write-Verbose "$Cmdlet`: $Message"
}