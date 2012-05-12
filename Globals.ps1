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


$AUTHKEY = $settings[6]
$PRIVKEY = $settings[7]

$shutdownDT = @(2012,1,1,1,1,0,10,2)
$shutdownOIDs = @($settings.yearOID,$settings.monthOID,$settings.dayOID,$settings.hourOID,$settings.minuteOID,$settings.secondOID,$settings.lotOID,$settings.schedOID)
$sdRadioIPAddrs = @{}

$baseName = $settings[15]
$radioWait = 0
$shutdownlenChosen = $false
$dateTimeChosen = $false
$meshGrpChosen = $false
$requestTypeChosen = $fase

#Create Some Temporary Files for streaming input and output
$outputfile = [IO.Path]::GetTempFileName() 
$inputfile = [IO.Path]::GetTempFileName()

function RadioShutdown ($RadioIPs, $TimeAndDate, $LengthOfSD) {
	# Try one or more commands
	try {
		foreach ($IPAddr in $RadioIPs) {
			for ($i=0; $i -lt $shutdownDT.Count; $i++) {
				TestShutDown $shutdownOIDs[$i] $shutdownDT[$i]
				#-addr $IPAddr -V 3 -u WMS -l authPriv -a SHA -A $AUTHKEY -p DES -P $PRIVKEY -O $shutdownOID[$i] -int $shutdownDT[$i]
			}
			Start-Sleep -s $radioWait
		}
	}
	# Catch specific types of exceptions thrown by one of those commands
	catch [System.IO.IOException] {
	}
}

function AllSet () {
	if ( $shutdownlenChosen -and $dateTimeChosen -and $meshGrpChosen -and $requestTypeChosen ) {
		$ShutDownExecbtn.Enabled = $true
	#} else {
	#	[void][System.Windows.Forms.MessageBox]::Show("All Parameters Must Be Chosen")
	}
}

function TestShutDown ($currentOID, $currOIDParm) {
	$StartInfo = new-object System.Diagnostics.ProcessStartInfo
	$StartInfo.FileName = "c:\opt\SnmpSet.exe"
	$StartInfo.Arguments= "-addr $IPAddr -V 3 -u WMS -l authPriv -a SHA -A $authKey -p DES -P $privKey -O $currentOID -int $currOIDParm"
	$StartInfo.LoadUserProfile = $false
	$StartInfo.UseShellExecute = $false
	$StartInfo.WorkingDirectory = (get-location).Path
	$proc = [System.Diagnostics.Process]::Start($StartInfo)
	Log "c:\opt\testlog.txt" $StartInfo
}