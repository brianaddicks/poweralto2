function Get-PaSecurityRule {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $Xpath = "/config/devices/entry/vsys/entry/rulebase/security/rules"

    #if ($Name) { $Xpath += "/entry[@name='$Name']" }

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    
    $RuleData = Get-PaConfig -Xpath $Xpath -Action $Action

    if ($RuleData.rules) { $RuleData = $RuleData.rules.entry } `
                    else { $RuleData = $RuleData.entry       }
        
    $RuleCount = 0
    $RuleTable = @()
    foreach ($r in $RuleData) {
        $RuleObject = New-Object PowerAlto.SecurityRule

        # Number
        $RuleCount++
        $RuleObject.Number = $RuleCount
        
        # General
        $RuleObject.Name        = $r.Name
        $RuleObject.Description = $r.Description
        $RuleObject.Tags        = HelperGetPropertyMembers $r tag

        # Source
        $RuleObject.SourceZone    = HelperGetPropertyMembers $r from
        $RuleObject.SourceAddress = HelperGetPropertyMembers $r source
        if ($r.'negate-source' -eq 'yes') { $RuleObject.SourceNegate = $true }

        # User
        $RuleObject.SourceUser = HelperGetPropertyMembers $r source-user
        $RuleObject.HipProfile = HelperGetPropertyMembers $r hip-profiles

        # Destination
        $RuleObject.DestinationZone    = HelperGetPropertyMembers $r to
        $RuleObject.DestinationAddress = HelperGetPropertyMembers $r destination
        if ($r.'negate-destination' -eq 'yes') { $RuleObject.DestinationNegate = $true }

        # Application
        $RuleObject.Application = HelperGetPropertyMembers $r application

        # Service / Url Category
        $RuleObject.UrlCategory = HelperGetPropertyMembers $r category
        $RuleObject.Service     = HelperGetPropertyMembers $r service

        # Action Setting
        if ($r.action -eq 'allow') { $RuleObject.Allow = $true } `
                              else { $RuleObject.Allow = $false }

        # Profile Setting
        $ProfileSetting = $r.'profile-setting'
        if ($ProfileSetting.profiles) {
            $RuleObject.AntivirusProfile     = $ProfileSetting.profiles.virus.member
            $RuleObject.AntiSpywareProfile   = $ProfileSetting.profiles.spyware.member
            $RuleObject.VulnerabilityProfile = $ProfileSetting.profiles.vulnerability.member
            $RuleObject.UrlFilteringProfile  = $ProfileSetting.profiles.'url-filtering'.member
            $RuleObject.FileBlockingProfile  = $ProfileSetting.profiles.'file-blocking'.member
            $RuleObject.DataFilteringProfile = $ProfileSetting.profiles.'data-filtering'.member
        } elseif ($ProfileSetting.group) {
            if ($ProfileSetting.group.member) { $RuleObject.ProfileGroup = $ProfileSetting.group.member }
        }

        # Log Setting
        if ($r.'log-start' -eq 'yes') { $RuleObject.LogAtSessionStart = $true }
        if ($r.'log-end' -eq 'yes')   { $RuleObject.LogAtSessionEnd = $true   }
        $RuleObject.LogForwarding = $r.'log-setting'

        # QoS Settings
        $QosSetting = $r.qos.marking
        if ($QosSetting.'ip-precedence') {
            $RuleObject.QosType    = "ip-precedence"
            $RuleObject.QosMarking = $QosSetting.'ip-precedence'
        } elseif ($QosSetting.'ip-dscp') {
            $RuleObject.QosType    = "ip-dscp"
            $RuleObject.QosMarking = $QosSetting.'ip-dscp'
        }

        # Other Settings
        $RuleObject.Schedule = $r.schedule
        if ($r.option.'disable-server-response-inspection' -eq 'yes') { $RuleObject.DisableSRI = $true }
        if ($r.disabled -eq 'yes') { $RuleObject.Disabled = $true }

        $RuleTable += $RuleObject
    }
    
    if ($Name) {
        $RuleTable = $RuleTable | ? { $_.Name -eq $Name }
    }

    return $RuleTable

}
