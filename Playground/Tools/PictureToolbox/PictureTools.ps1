
function Get-FileMetaData {
<# 
    .SYNOPSIS
    Gets the file meta data from provided folder

    .DESCRIPTION
    Gets the file meta data from the provided folder using the FolderItem object.

    .PARAMETER FilePath
    Path to one or more folders where image files are located

    .PARAMETER Extension
    One or more image file extensions, such as .jpg and .gif
    If no extensions are specified, the script looks for .jpg and .gif 
    image files by default.

    .EXAMPLE
    Get-FolderMetaData -Source $PicturePath -Extension @(".jpeg";".jpg") -Verbose
    This example will return information on files with .jpg extension in the given folder and its subfolders
  
    .OUTPUTS
    Script will return an array of PS Objects, with all found properties.   

    .LINK


    .NOTES
    This script includes some snippets from below authors

    Author 1: https://superwidgets.wordpress.com/2014/08/15/powershell-script-to-get-detailed-image-file-information-such-as-datetaken/
    Author 2: https://gallery.technet.microsoft.com/scriptcenter/get-file-meta-data-function-f9e8d804
    
#>
#Requires -Version 4
[CmdletBinding()] 
Param(
[Parameter(Mandatory=$true,  Position=0)]
    [ValidateScript({ (Test-Path -Path $_) })]
    [String[]]$FilePath, 

[Parameter(Mandatory=$false, Position=1)]
    [String[]]$Extension = @('.jpg','.gif')

)

    # iColumn is the integer value for that specifies the information to be retrieved from the FolderItem object.
    # 157 is the default value for Windows 10
    # More information from https://msdn.microsoft.com/en-us/library/windows/desktop/bb787870(v=vs.85).aspx
    
    Write-Verbose "Getting files from '$FilePath' with extension(s) '$Extension'."
         
    # Get folder list
    $Folders = @()
    $Duration = Measure-Command { 
        $FilePath | ForEach-Object { 
            $Folder = ""
            $Folder = (Get-ChildItem -Path $FilePath -Recurse -Directory -Force).FullName 
            if($Folder){ $Folders += $Folder }
        }
      $Folders += $FilePath
        
    }

    Write-Verbose "Got '$($Folders.Count)' folder(s) in $($Duration.Minutes):$($Duration.Seconds) mm:ss"
    
    $FileMetaDatas = @()
    $objShell  = New-Object -ComObject Shell.Application

    # Get file metadata from each folder
    $Folders | ForEach-Object {

        $objFolder = $objShell.namespace($_)
        $Path = $_

        foreach ($File in $objFolder.items()) { 

            # Get file extension from FolderItem Item object
            $FileName = $objFolder.getDetailsOf($File, 0)
            $FilePath = "$Path\$FileName"
            $FileExtension = (Get-Item $FilePath -ErrorAction Ignore).Extension

            # Check if the extension matches provided values and extract file metadata
            if ($FileExtension -in $Extension) {

                Write-Verbose "Processing file '$($File.Path)'"

                $FileMetaDataDetails = New-Object PSObject

                $a = 0
                for ($a ; $a  -le 266; $a++) {
                    $hash += @{$($objFolder.getDetailsOf($objFolder.items, $a)) = $($objFolder.getDetailsOf($File, $a)) } 
                    $FileMetaDataDetails | Add-Member $hash -ErrorAction Ignore
                    $hash.clear()  
                }

                $FileItem = Get-ChildItem -Path $FilePath;
                $FileMD5 = Get-FileHash -Path $FilePath -Algorithm MD5;

	            $FileMetaData = @{
                    FilePath 			= $FilePath;
                    FileName 			= $FileName;
                    FileExtension       = $FileExtension;
                    FileMetaDataDetails	= $FileMetaDataDetails;
		            ChildItem 			= $FileItem;
                    FileMD5             = $FileMD5;
        	
	            };
            
                $FileMetaDatas += $FileMetaData
            }
            
        }

    }

    Return $FileMetaDatas

}

function Get-FileMetaDataPictureDate {
<# 
    .SYNOPSIS
    Gets the picture date from the file metadata

    .DESCRIPTION
    Tries to get the most accurate picture date from the original file names.

    .PARAMETER FileMetaData
    Input the FileMetaData Object to check all 

    .EXAMPLE

  
    .OUTPUTS


    .LINK


    .NOTES

    
#>
#Requires -Version 4
[CmdletBinding()] 
Param(
[Parameter(Mandatory=$true,  Position=0)]
    [Object[]]$FileMetaData

)
    Write-Verbose "Getting picture dates."

    foreach ($MetaData in $FileMetaData) {

        $FileName 	= $MetaData.FileName

        $DateTaken 	= $MetaData.FileMetaDataDetails.'Date taken'
        $DateTaken  = $DateTaken -replace '[^a-zA-Z0-9\/: ]', ''
        Write-Verbose "Processesing '$FileName'."
   
        # Get Date (FileName > Date Taken > File Date Modified)
        # FileName Formats: 
        # $FileName = "2014-02-14 16.55.30.jpg"
        # $FileName = "20140211132236-2160.jpg"
        # $FileName = "20140305091538-2-2160.jpg"
        # $FileName = "IMG_20151209_103251.jpg"
        # $FileName = "IMGD2014-02-14 16.55.30.jpg"
        # $FileName = "20140211132236-2160.jpg"
        # $FileName = "x.jpg"
        
        $sDate = ""
        $RegexDateFormat1 			= "(\d{4}-\d{2}-\d{2} \d{2}.\d{2}.\d{2})"
        $RegexDateFormat2 			= "(\d{4}\d{2}\d{2}\d{2}\d{2}\d{2})"
        $RegexDateFormat3 			= "(\d{4}\d{2}\d{2}_\d{2}\d{2}\d{2})"
        $RegexDateFormatDateTaken 	= "(\d{2}\/\d{2}\/\d{4} \d{2}:\d{2})"

        if ($FileName -match $RegexDateFormat1) {
            $Date = $FileName -split $RegexDateFormat1
            $sDate = $Date[1] 
            $sDate = $sDate.Replace(" ","T")
            $sDate = $sDate.Replace(".",":")
        }elseif($FileName -match $RegexDateFormat2) {
            $Date = $FileName -split $RegexDateFormat2
            $sDate = $Date[1] 
            $sDate = $sDate.Insert(4,'-').Insert(7,'-').Insert(10,'T').Insert(13,':').Insert(16,':')
        }elseif($FileName -match $RegexDateFormat3) {
            $Date = $FileName -split $RegexDateFormat3
            $sDate = $Date[1] 
            $sDate = $sDate.Replace("_","T")
            $sDate = $sDate.Insert(4,'-').Insert(7,'-').Insert(13,':').Insert(16,':')
        }elseif($DateTaken -match $RegexDateFormatDateTaken){

            $Date = $DateTaken -split $RegexDateFormatDateTaken
            $sDate = $Date[1] 
            $sDate = "$($sDate.Substring(6,4))-$($sDate.Substring(3,2))-$($sDate.Substring(0,2))T$($sDate.Substring(11,2)):$($sDate.Substring(14,2)):00"

        }else{

            $sDate = $MetaData.ChildItem.LastWriteTime.toString("o").Substring(0,19)
            
        }




        
    
        if ((Test-DateTimePattern -String $sDate -Pattern s -ErrorAction Ignore) -and $sDate) {
            $DateTime 					= [datetime]$sDate 
            $MetaData.PictureDateTime 	= $DateTime
        }
        
        
    }

    return $FileMetaData

}

function Move-FileMetaDataPictureDate {
<# 
    .SYNOPSIS
    Gets the picture date from the file metadata

    .DESCRIPTION
    Tries to get the most accurate picture date from the original file names.

    .PARAMETER FileMetaData
    Input the FileMetaData Object to check all 

    .EXAMPLE

  
    .OUTPUTS


    .LINK


    .NOTES

    
#>
#Requires -Version 4
[CmdletBinding()] 
Param(
[Parameter(Mandatory=$true,  Position=0)]
    [Object[]]$Images

)

    foreach ($Image in $Images) {
        # $Image.FilePath
        # $Image.PictureDateTime 
        # $Image.FileExtension 
        $a 						= 0;
        $isDuplicate 			= $false;
        $isExisting 			= $false;
        $isMoved 				= $false;
        $isPictureDateMissing 	= $false;
        $CurrentFilePath 	= $Image.FilePath;


        if($Image.PictureDateTime) {
            $Year 				= $Image.PictureDateTime.Year;
            $Month 				= "0$($Image.PictureDateTime.Month)";
            $Month 				= $Month.Substring($Month.length - 2, 2);


            do {
                $NewFolder 				= "$Destination\$Year\$Month"
                if ($a -eq 0) {
                    $NewFileName 		= "$($Image.PictureDateTime.ToString("o").Substring(0,19).Replace(":","."))"
                    $NewFilePath 		= "$NewFolder\$NewFileName$($Image.FileExtension)"
                }else{
                    $NewFileName 		= "$($Image.PictureDateTime.ToString("o").Substring(0,19).Replace(":","."))"
                    $NewFilePath 		= "$NewFolder\$NewFileName-$a$($Image.FileExtension)"
                }
                if(Test-Path -Path $NewFilePath){
                    $isExisting 		= $true
                
                    # Check MD5
                    $md5ExistingFile 	= (Get-FileHash -Path $NewFilePath -Algorithm MD5).Hash
                    $md5NewFile 		= $Image.FileMD5.Hash

                    if($md5ExistingFile -eq $md5NewFile){
                        Write-Verbose "Duplicate file '$NewFilePath' with MD5 Hash '$md5NewFile'." 
                        $isDuplicate 	= $true
                    }

                }else{
                    #notexisting
                    Write-Verbose "Moving file '$NewFilePath'." 

                    if(!(Test-Path -Path $NewFolder)){ New-Item -Path $NewFolder -ItemType Directory -Force | Out-Null }

                    Move-Item -Path $CurrentFilePath -Destination $NewFilePath -Force
                    $isMoved 			= $true

                }
            
                $a++

            }until(($isMoved) -or ($a -eq 99) -or ($isDuplicate));
        
            $Image.NewFileName 				= $NewFileName
            $Image.NewFilePath 				= $NewFilePath

        }else{
            Write-Verbose "Picture Date is missing for file '$CurrentFilePath'." 
            $isPictureDateMissing 		= $true
        }

        $Image.isMoved 					= $isMoved
        $Image.isDuplicate 				= $isDuplicate
        $Image.isExisting 				= $isExisting
        $Image.isPictureDateMissing 	= $isPictureDateMissing

    }

    return $Images

}


function Test-DateTimePattern
{
[CmdletBinding()] 
Param(
[string]$String,
[string]$Pattern,
[System.Globalization.CultureInfo]$Culture = (Get-Culture),
[switch]$PassThru
)

    $result = try{ [DateTime]::ParseExact($String,$Pattern,$Culture) } catch{}

    if($PassThru -and $result)
    {
        $result
    }
    else
    {
        [bool]$result
    }
}

