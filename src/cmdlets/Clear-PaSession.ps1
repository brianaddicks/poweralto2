function Clear-PaSession {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,ParameterSetName="Id",Position=0)]
        [int]$Id,
		
		[Parameter(Mandatory=$True,ParameterSetName="Session",Position=0)]
        [PowerAlto.Session]$Session,
    )

    $ReturnObject = @()
    
    

    if ($Id) {
        $Command = "<show><session><id>$Id</id></session></show>"
    } elseif ($FilterString -ne "") {
        $Command = "<show><session><all><filter>$FilterString</filter></all></session></show>"
    } else {
        $Command = "<show><session><all></all></session></show>"
        #Throw "Must specifiy an Id or a Filter"
    }
	
    $ResponseData = Invoke-PaOperation $Command
    

    return $ReturnObject
}