function getpassword {
	$password = Read-Host -AsSecureString -Prompt "New password"
	$passwordcheck = Read-Host -AsSecureString -Prompt "New password (confirm)"
	
	$password_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
	$passwordcheck_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwordcheck))
	
	if ($password_text -ne $passwordcheck_text) {
		Write-Warning -Message "Password's do not match!"
		getpasssword
	}
	else {
		return $password
	}
}

$local_user = Read-Host -Prompt "Local account username"
$new_password = getpassword

Write-Host -nonewline "Fetching computer list..."

$computers = (Get-ADComputer -Filter 'Enabled -eq $true -and OperatingSystem -like "Windows*"').Name
$computercount = $computers.Length

Write-Host "done."

Write-Output "Found $computercount enabled Windows computers in Active Directory."

$remotescript = {
	Set-LocalUser -Name $Using:local_user -Password $Using:new_password
	Enable-LocalUser -Name $Using:local_user
	Write-Host -ForegroundColor Green "$(hostname): Done"
}

$reply = Read-Host -Prompt "Ready to update password for local account '$local_user' on $computercount computers, proceed? [y/n]"

if ($reply -match "[yY]") {
	Invoke-Command -ComputerName $computers -ScriptBlock $remotescript
	Write-Output "Complete"
}
else {
	Write-Output "Cancelled"
}
