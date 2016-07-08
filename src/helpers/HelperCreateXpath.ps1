function HelperCreateXpath {
    Param (
        [Parameter(Mandatory=$True,Position=0)]
		[string]$Node
    )

    $DeviceType  = ($Global:PaDeviceObject).Type
    $DeviceGroup = ($Global:PaDeviceObject).DeviceGroup
    switch ($DeviceType) {
        panorama {
            switch ($DeviceGroup) {
                shared {
                    $Xpath = "/config/shared/$Node"
                    break
                }
                default {
                    $Xpath = "/config/devices/entry/device-group/entry[@name='$DeviceGroup']/$Node"
                    break
                }
            }
            break
        }
        firewall {
            $Xpath = "/config/devices/entry/vsys/entry/$Node"
            break
        }
    }
    
    return $Xpath
}