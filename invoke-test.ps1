#Guest VM Credentials
$guestAdmin = "CHANGEME"
$guestPassword = ConvertTo-SecureString “CHANGEME” -AsPlainText -Force
$guestCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $guestAdmin, $guestPassword

#Guest VM domain Credentials
$DomainAccountPWD = 'CHANGEME'
$userID = 'CHANGEME'

#Works but requires WinRM and CredSSP configuration
$ScriptText01 = "
`username = CHANGEME
`$pass = 'CHANGEME' 
`$cred = New-Object System.Managment.Automation.PSCredential -ArgumentList @(`$username,(ConvertTo-SecureString -String `$pass -Asplaintext -Force))
invoke-command -Computername QWS01 -ScriptBlock {C:\Users\xadministrator\Desktop\test.ps1} -Authentication Credssp -Credential `$cred
"

#create new .ps file to run
$ScriptText02 = "
echo `"```$domain = `'quarantine`'
```$password = `'$DomainAccountPWD`' | ConvertTo-SecureString -asPlainText -force;
```$username = `'$userID`';
```$credential = New-Object System.Management.Automation.PSCredential(```$username, ```$password);
Add-computer -DomainName ```$domain -Credential ```$credential`" > C:\Users\CHANGEME\Desktop\test.ps1
"

#attempt domain join directly from console
$cmd = @"
`$domain = "quarantine"
`$password = "$DomainAccountPWD" | ConvertTo-SecureString -asPlainText -force;
`$username = "$userID";
`$credential = New-Object System.Management.Automation.PSCredential(`$username, `$password);
Add-computer -DomainName `$domain -Credential `$credential
"@

Invoke-VMScript -ScriptText $ScriptText02 -vm $NewVMName -GuestCredential $guestCredential -ScriptType Powershell

