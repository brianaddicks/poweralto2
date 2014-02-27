$Device = "pegasus.addicks.us"
$ApiKey = "LUFRPT1PR2JtSDl5M2tjTktBeTkyaGZMTURTTU9BZm89OFA0Rk1WMS8zZGtKN0FmVjRqQ0lxVHlRcmgvSVRoUnlzMW5OckNhVEZUZz0="
ipmo C:\dev\poweralto2\poweralto2.psm1
Get-PaDevice $Device $ApiKey
$global:Test = new-object PowerAlto.SecurityRule
$global:Test
