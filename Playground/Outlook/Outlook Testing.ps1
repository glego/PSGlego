Function SaveAttachments() {
[CmdletBinding()]
Param(
    [parameter(Mandatory=$true)]
    [object]$Items,

    [parameter(Mandatory=$true)]
    [string]$Path

)

# Check if the directory exists, if not than create directory
if (!(Test-Path $Path)) {
    New-Item -Path $Path -type directory -Force -ErrorAction SilentlyContinue
}

# Loop through all the Email Items
foreach ($Item in $Items) {
    
    # $Item
    $ItemSubject = $Item.Subject
    $ItemDate = $Item.ReceivedTime.ToString("yyyy-MM-ddThh.mm.ss")

    if ($Item.Attachments.Count -gt 0) {
        Write-Host "Found '$($Item.Attachments.Count)' attachments in email '$ItemSubject'"
        foreach ($ItemAttachment in $Item.Attachments) {
            
            $AttachmentFilePath = ($ItemDate + "-" + $Subject + "-" + $ItemAttachment.DisplayName)
            $AttachmentFilePath = (ConverTo-WindowsFileName -Text $AttachmentFilePath)
            $AttachmentFilePath = ($Path + "\" + $AttachmentFilePath)

            if (!(Test-Path $AttachmentFilePath)) {
                Write-Host "Saving file: '$AttachmentFilePath'"
                $ItemAttachment.SaveAsFile($AttachmentFilePath)
            }else{
                Write-Warning "File Already exists '$AttachmentFilePath'"
            }


        }
    }

}

}
Function ConverTo-WindowsFileName {
<#
.Synopsis
   Converts a given text to an valid Windows Filename
   
.DESCRIPTION
   Converts a given text to an valid Windows Filename
   This function defines rules to fit a given Text to the Microsoft Windows file naming Conventions
   The following fundamental rules are processed to the given text to create an valid filename:
   - Removes all leading and trailing white-space characters
   - Removes all leading (and trailing) period (dot) characters (for Unix compatibility)
   - Allows only the characters in the American alphabet:
   	uppercase characters A-Z lowercase characters a-z Numbers 0-9  underscore_ and the hyphen - (minus sign).
	All other characters will be replaced by the underscore _.
   - Converts German Umlauts to allowed American chars.	
   
   Case sensitivity will not be changed but do not assume case sensitivity, because characters will be replaced by underscaore!
   
   For Microsoft filename rules see:
   Naming Files, Paths, and Namespaces
   http://msdn.microsoft.com/en-us/library/windows/desktop/aa365247%28v=vs.85%29.aspx
   
.PARAMETER $Text
	The String (text) that will be converted into the filename
   
.EXAMPLE
   ConverTo-WindowsFileName "Hans + Günther Mäßig: 31.12.2012 Überlingen 2 & 10€ @microsoft /in \the hand?"
   
   Output is the filename: 'Hans___Guenther_Maessig__31-12-2012_Ueberlingen_2_and_10___microsoft__in__the_hand_'
 
.OUTPUTS
   filename as Type of System.String on success, on failure empty System.String
   
.NOTES
   Author: Peter Kriegel
   initial release:
   Version: 1.0 21.March.2014
#>
	
	param(
		[String]$Text
	)
	
	# Removes all leading and trailing white-space characters
	$Text = $Text.Trim()
	
	# Removes all leading and trailing period (dot) characters
	# $Text = $Text.Trim([Char]'.')
	
	# Removes all leading and trailing front-slashes characters
	$Text = $Text.Trim([Char]'/')
	
	# Removes all leading and trailing back-slashes characters
	$Text = $Text.Trim([Char]'\')
	
	# Replace German umlauts (upper- and lowercase)
	$Text = $Text.Replace("ä", "ae")
	$Text = $Text.Replace("ö", "oe")
	$Text = $Text.Replace("ü", "ue")	
	$Text = $Text.Replace("Ä", "Ae")
	$Text = $Text.Replace("Ö", "Oe")
	$Text = $Text.Replace("Ü", "Ue")
	$Text = $Text.Replace("Ü", "Ue")
	$Text = $Text.Replace("ß", "ss")
	
	# using Regular Expressions to replace any whitespace character (Tabulatur, Space ...) with the underscore
	# this line is unnecessary because later we use a rule to replace all unknown chars with the underscore
	# I leave this line, because the later used rule is a subject to change... 
	$Text = $Text -replace('\s','_')
	
	# replace the ampersand & with the word 'and' (used in German company names)
	$Text = $Text.Replace("&", "and")
	
	# to display German calendar dates correctly in the Filename,
	# we replace every dot  with the hyphen (minus sign).
	# 31.12.2012 will be translated to 31-12-2012)
	#$Text = $Text.Replace(".", "-")
	
	# create Array with chars allowed in Windows (and unix and Mac) Filenames
	$WhiteListCharArray = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-.".ToCharArray()
	
	# create a StringBuilder to speed up the text processing
	$StringBuilder = New-Object System.Text.StringBuilder
	
	# Now we use a rule to replace every char that is not in the whitelist with an underscore
	ForEach($TextChar in $Text.ToCharArray()) {
		If($WhiteListCharArray -contains $TextChar) {
			[Void]$StringBuilder.Append($TextChar)
		} Else {
			[Void]$StringBuilder.Append('_')
		}
	}
	
	# convert StringBuilder to a String
	$Text = $StringBuilder.ToString()
	
	# Removes all leading and trailing hyphen (minus sign) characters
	$Text = $Text.Trim([Char]'-')
	
	# throw Error if the Text is to long for a Windows filename
	If($Text.Length -gt 256) {
		throw [IO.PathTooLongException]("Path too long! $Text")
		return ''
	}
	
	# check if the Filename is valid now
	Try {
		# For creating a FileInfo Object instance the file does not need to exist.
		$Null = New-Object System.IO.FileInfo($Text)
	} Catch {
		Throw [System.ArgumentException]("Illegal characters in path: $Text")#
		return ''
	}
  	
	# return the result
	return $Text
}


$AttachmentsPath = "C:\tmp\PowershellSaveAttachments"

#connect to outlook
$Outlook = New-Object -com "Outlook.Application"; 
$NameSpace = $Outlook.GetNamespace("MAPI")

$InboxFolder = $NameSpace.GetDefaultFolder(‘olFolderInbox’)

$InboxName = $InboxFolder.Namest
$InboxItems = $InboxFolder.items

SaveAttachments -Items $InboxItems -Path $AttachmentsPath


break

$olxEmailItem = $olxemailFolder.items


$SubFolders = $olxEmailFolder.Folders
ForEach($Folder in $SubFolders)
{
    $Folder.Name
}


break






#show unread emails in inbox
$olxEmailItem | ?{$_.Unread -eq $True} | select SentOn, SenderName, Subject, Body | Format-Table -auto


#go through each subfolder and get name
$SubFolders = $olxEmailFolder.Folders
ForEach($Folder in $SubFolders)
{
	$Folder.Name
	$SubfolderItem = $Folder.Items
	$EmailCount = 1
#create status bar for each subfolder
	ForEach($Email in $SubfolderItem)
	{
		Do
		{
			Write-Progress -Activity "Checking folder" -status $Folder.Name -

PercentComplete ($EmailCount/$Folder.Items.Count*100)
			$EmailCount++
		}
#show unread emails from subfolders
		While($EmailCount -le $Folders.Item.Count)
	$Email | ?{$_.Unread -eq $True} | select SentOn, SenderName, Subject, Body | Format-Table -

Auto
	}
}

break


#connect to tasks
$olxTasksFolder = $olName.GetDefaultFolder(‘olFolderTasks’)
$olxTaskItems = $olxTasksFolder.items
$TaskCount = 1
#create task array
$TaskList = @()
ForEach($TaskItem in $olxTaskItems)
{
#create status bar for tasks
	Do
	{
		Write-Progress -Activity "Checking" -status "Tasks" -PercentComplete ($Taskcount/

$olxTasksFolder.Items.count*100)
		$TaskCount++
	}
#add each incomplete tash to array
	While($TaskCount -le $olxTaskFolder.Items.Count)
	If($TaskItem.Complete -eq $False)
	{
	$TaskList+=New-Object -TypeName PSObject -Property @{
	Subject=$TaskItem.Subject
	DateCreated=$TaskItem.CreationTime
	Percent=$TaskItem.PercentComplete
	Due=$TaskItem.DueDate
	}}
}
#show task array to screen
$TaskList | Sort DueDate -descending | Format-Table -Auto