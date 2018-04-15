# Email Configuration

$SMTPServer			= "smtp.email.com";
$SMTPPort		 	= 587;
$SMTPUserName		= "alerts@email.com";
$SMTPPassword		= "password";
$SMTPSSL 			= $true;

# Email

$EmailFrom			= "alerts@email.come";
$EmailTo			= "alerts@email.com";
$Subject 			= "Sendlog";
$Body 				= "Some Test";

# Attachements

$FileAttachment 	= "E:\temp\log.log";

# Send Email

$Message 			= New-Object Net.Mail.MailMessage;
$Message.From 		= $EmailFrom;
$Message.Subject 	= $Subject;
$Message.Body 		= $Body;

$Message.to.Add($EmailTo);

$Attachment = New-Object Net.Mail.Attachment($FileAttachment);
$Message.Attachments.Add($Attachment);

$SMTPClient 			= New-Object Net.Mail.SmtpClient($SMTPServer, $SMTPPort);
$SMTPClient.EnableSsl 	= $SMTPSSL;
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($SMTPUserName, $SMTPPassword); 

$SMTPClient.Send($Message);

