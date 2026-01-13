#Usage  .\AddUser.ps1 -FirstName Fore -LastName Last -Password password -Dept Fake -City Exampletown -Phone 3333333333 -Title JobTitle -ReferenceUser olduser@domain.com -Domain domain.com

param (
    	[string]$FirstName,
	[string]$LastName,
	[string]$Password,
	[string]$Dept,
	[string]$City,
	[string]$UPN,
	[string]$Phone,
	[string]$Title,
	[string]$ReferenceUser,
	[string]$Domain
)

if (-not $Password) {$Password = "welcome"}
if (-not $ReferenceUser) {$ReferenceUser = "no-reply@($Domain)"}
$UPN_A = ""

#Prepare the log file
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = ".\AddUser_$($timestamp).txt"

#Populate UPN
if (-not $UPN) {$UPN = "$($FirstName[0])$($LastName)@($DomainName)"} #Defining UPN

#Log file
"Detected user $($FirstName) $($LastName) with display name $($DisplayName) at UPN $($UPN) and in city $($City) and Department $($Dept) with phone $($Phone)" | Out-File -Append -FilePath $logFile

#This string shows a screen which allows us to validate
#Use the UI
	try {
		$response = 1
		while ($response -ne 'Y') {
		write-host "Creating a user with the following values:"
		write-host "[1] First Name: $($FirstName)"
		write-host "[2] Last Name: $($LastName)"
		write-host "[3] A request was detected for email $($UPN_A) and will in fact create $($UPN)"
		write-host "[4] Job Title: $($TItle)"
		write-host "[5] City: $($City)"
		write-host "[6] Department: $($Dept)"
		if ($Phone -ne $null) {write-host "[7] Phone: $($Phone) (will be defined in AD)"} else {write-host "[8] Phone: None entered"}
		write-host "Full Name will be $($DisplayName)"
		write-host "--- Press 0 to add a user with these changes. Press 1 to edit First Name. Press 2 to edit Surname. Press 3 to edit UPN. Press 4 to edit Title. Press 5 to edit City. Press 6 to edit Department. Press 7 to edit phone. Press 8 to clear phone. Press 9 to abort. ---"
		$response = read-host -prompt "Enter your choice."
		switch ($response) {
		1 {$FirstName = read-host -prompt "Enter first name."} 
		2 {$LastName = read-host -prompt "Enter last name."}
		3 {$UPN = read-host -prompt "Enter the UPN."}
		4 {$Title = read-host -prompt "Enter user title."}
		5 {$City = read-host -prompt "Enter new city."}
		6 {$Dept = read-host -prompt "Enter department."}
		7 {$Phone = read-host -prompt "Enter user phone."}
		8 {$Phone = $null}
		9 {exit}
		'Y' {$response = 1}
	 	}
		if ($response -eq 0) {$response = read-host -prompt "Are you sure? Y/N"}
	}
	}
	catch {
		Write-Warning "Invalid Entry. See error: $_"
	}

#Writes to AD
Write-Host "Attempting to connect to AzureAD...."
"Attempting to connect to AzureAD...." | Out-File -Append -FilePath $logFile
try {
	Connect-AzureAd
	if (-not $DisplayName) {$DisplayName = "$($FirstName) $($LastName)"}
	$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
	$PasswordProfile.Password = $Password

		#Defining the parameters for the command.
	$user_params = @{
	AccountEnabled = $true
	DisplayName = $DisplayName
	PasswordProfile = $PasswordProfile
	UserPrincipalName = $UPN
	Department = $Dept
	GivenName = $FirstName
	Surname = $LastName
	City = $City
	Country = "United States"
	}
	if ($Phone -ne $null) {$user_params += @{TelephoneNumber = $Phone}}
	if ($Title -ne $null) {$user_params += @{JobTitle = $Title}}
	write-host "Creating a user with the following paramters:"
	write-host $user_params
	"Attempt to create the followng user has been initiated:" | Out-File -Append -FilePath $logFile
	$user_params | Out-File -Append -FilePath $logFile
	New-AzureADUser @user_params #Check to see if the at symbol needs to be a dollar sign instead.
	write-host "AD User successfully created!"
	"AD User successfully created!" | Out-File -Append -FilePath $logFile
}
catch {
	Write-Warning "$_"
	"User adding failed." | Out-File -Append -FilePath $logFile
}


write-host "User creaction process has finished with password $($Password)"
"User creation complete" | Out-File -Append -FilePath $logFile
read-host