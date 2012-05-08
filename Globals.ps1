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

$settings = Import-Csv -Delimiter "," -Path c:\opt\LEMSnmpset.ini
$meshpoints = Import-Csv -Delimiter "," -Path c:\opt\LEMRadioList.csv

$highestMesh = $settings.MeshE
$AUTHKEY = $settings.authKey
$PRIVKEY = $settings.privKey

$shutdownDT = @(2012,1,1,1,1,0,10,2)
$shutdownOIDs = @($settings.yearOID,$settings.monthOID,$settings.dayOID,$settings.hourOID,$settings.minuteOID,$settings.secondOID,$settings.lotOID,$settings.schedOID)
$sdRadioIPAddrs = @{}

$sdRadioSNMPV3User = "WMS"
$sdSNMPV3AuthType = "SHA"
$sdSNMPV3PrivType = "DES"
$radioWait = 0
$timePicked = ""
$shutdownlenChosen = 1
$dateTimeChosen = 1

function RadioShutdown ($RadioIPs, $TimeAndDate, $LengthOfSD) {
	# Try one or more commands
	try {
		foreach ($IPAddr in $RadioIPs) {
			for ($i=0; $i -lt $shutdownDT.Count; $i++) {
				& SnmpSet -addr $IPAddr -V 3 -u WMS -l authPriv -a SHA -A $AUTHKEY -p DES -P $PRIVKEY -O $shutdownOID[$i] -int $shutdownDT[$i]
			}
			Start-Sleep -s $radioWait
		}
	}
	# Catch specific types of exceptions thrown by one of those commands
	catch [System.IO.IOException] {
	}
}