function Send-Email () {
    <#
    .SYNOPSIS
        Send an email

    .DESCRIPTION
        Send an email

    .PARAMETER SmtpServer
        Provide the Server IP or DNS to send the email.

    .PARAMETER Port
        Provide the Server port number to connect.

    .PARAMETER UseSsl
        Use Secure Sockets Layer (SSL) protocol to establish a connection with the server. By default SSL is disabled.
    
    .PARAMETER Credential
        Provide the credential to perform this action. By default it's empty.
    
    .PARAMETER EmailFrom
        Provide the email address from which the email is sent from.
    
    .PARAMETER EmailTo
        Provide the email address(es) to where the email will be sent to.

    .PARAMETER Subject
        Provide the Subject header which 

    .PARAMETER Body
        Provide the body for the email message.

    .PARAMETER HtmlBody
        Provide the body as Html for the email message.

    .PARAMETER FileAttachement
        Provide the location of the attachments to be sent.

    .EXAMPLE
        Send-Email

    .LINK
        https://github.com/glego/PSGlego/Glego.PSUtility

    #>
    [CmdletBinding()]
    Param
    (

        [string]$SmtpServer = "localhost",
        [Int32]$Port=25,
        [switch]$UseSsl=$false,

        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Mandatory=$true)]
        [string]$EmailFrom,
        [parameter(Mandatory=$true,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string[]]$EmailTo,
        [Parameter(Mandatory=$true)]
        [string]$Subject,
        [string]$Body="",
        [string]$HtmlBody,
        [string[]]$FileAttachement
    )

    # Create a new Mail Message
    $MailMessage = New-Object Net.Mail.MailMessage;
    $MailMessage.From = $EmailFrom
    $MailMessage.Subject = $Subject

    # Add the Recipients
    $EmailTo | ForEach-Object {
        $MailMessage.to.Add($_)
    }

    # Add the Attachments
    $FileAttachement | ForEach-Object {
        if ($_){
            $Attachment = New-Object Net.Mail.Attachment($_)
            $MailMessage.Attachments.Add($Attachment)
        }
    }

    # Add the body
    If ($HtmlBody) {
        $AlternateViewBody = [System.Net.Mail.AlternateView]::CreateAlternateViewFromString($Body, $null, "text/plain");
        $AlternateViewHtmlBody = [System.Net.Mail.AlternateView]::CreateAlternateViewFromString($HtmlBody, $null, "text/html");
        
        $MailMessage.AlternateViews.Add($AlternateViewBody);
        $MailMessage.AlternateViews.Add($AlternateViewHtmlBody);
    
    } else {
        $MailMessage.Body = $Body;
    }

    # Create Smtp Client with Credentials
    $SmtpClient             = New-Object Net.Mail.SmtpClient($SmtpServer, $Port)
    $SmtpClient.EnableSsl   = $UseSsl
    $SmtpClient.Credentials = $Credential

    # Out with the message
    $SmtpClient.Send($MailMessage)
}