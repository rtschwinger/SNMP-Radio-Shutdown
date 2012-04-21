#--------------------------------------------
# Declare Global Variables and Functions here
#--------------------------------------------
function Log {
	param([string]$filename,[string]$text)
	Out-File $filename -append -noclobber -inputobject $text -encoding ASCII
}

#Sample function that provides the location of the script
function Get-ScriptDirectory
{ 
	if($hostinvocation -ne $null)
	{
		Split-Path $hostinvocation.MyCommand.path
	}
	else
	{
		Split-Path $script:MyInvocation.MyCommand.Path
	}
}

#Sample variable that provides the location of the script
[string]$ScriptDirectory = Get-ScriptDirectory

$settings = Import-Csv -Delimiter "," -Path c:\opt\Snmpset.ini
$meshpoints = Import-Csv -Delimiter "," -Path c:\opt\LEMRadioList.csv

$highestMesh = $settings.MeshE
$AUTHKEY = $settings.authKey
$PRIVKEY = $settings.privKey
$YEAROID = $settings.yearOID
$MONTHOID = $settings.monthOID
$DAYOID = $settings.dayOID
$HOUROID = $settings.hourOID
$MINOID = $settings.minuteOID
$SECOID = $settings.secondOID
$LOTOID = $settings.lotOID
$SCHEDOID = $settings.schedOID

$sdTimeLength = 10
$shutDownYR = 2012
$shutDownMO = 1
$shutDownDAY = 1
$shutDownHOUR = 0
$shutDownMIN = 0
$shutDownSEC = 0
$sdRadioIPAddr = "10.0.50.80"
$sdRadioSNMPV3User = "WMS"
$sdSNMPV3AuthType = "SHA"
$sdSNMPV3PrivType = "DES"