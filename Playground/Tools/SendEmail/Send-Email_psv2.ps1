$ErrorActionPreference = "Stop"

# Email Configuration

$SMTPServer			= "smtp.example.com";
$SMTPPort		 	= 587;
$SMTPUserName		= "alerts@example.com";
$SMTPPassword		= "Password";
$SMTPSSL 			= $true;

# Email

$EmailFrom			= "alerts@example.com";
$Subject 			= "Sendlog 2 test 2";

$EmailsTo			= ("alerts@example.com");

$plainBody = "This is my plain text content, viewable by those clients that don't support html"
$htmlBody = "<b>this is bold text, and viewable by those mail clients that support html</b>"

# Attachments

$FileAttachments 	= ("");



# Create Message

$Message 			= New-Object Net.Mail.MailMessage;
$Message.From 		= $EmailFrom;
$Message.Subject 	= $Subject;

If ($htmlBody) {
    $AVplainBody = [System.Net.Mail.AlternateView]::CreateAlternateViewFromString($plainBody, $null, "text/plain");
    $AVhtmlBody = [System.Net.Mail.AlternateView]::CreateAlternateViewFromString($htmlBody, $null, "text/html");

    $Message.AlternateViews.Add($AVplainBody);
    $Message.AlternateViews.Add($AVhtmlBody);

} else {
    $Message.Body 		= $plainBody;
}

if ($EmailsTo) {
    ForEach ($EmailTo in $EmailsTo) {
        $Message.to.Add($EmailTo);
    }
}

if ($FileAttachments) {
    ForEach ($FileAttachment in $FileAttachments) {
        $Attachment = New-Object Net.Mail.Attachment($FileAttachment);
        $Message.Attachments.Add($Attachment);
    }
}

# Send Email
$SMTPClient 			= New-Object Net.Mail.SmtpClient($SMTPServer, $SMTPPort);
$SMTPClient.EnableSsl 	= $SMTPSSL;
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($SMTPUserName, $SMTPPassword); 

$SMTPClient.Send($Message);

#$Attachment.Dispose() #dispose or it'll lock the file

