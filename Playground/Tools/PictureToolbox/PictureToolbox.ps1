#Requires -Version 4
[CmdletBinding()]
Param()

$ErrorActionPreference = "Stop"

Function Get-Picture {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [String]$FilePath,

        [Parameter(Mandatory=$false, Position=1)]
        [String[]]$Extension = @(".jpeg";".jpg")
    )

    Write-Verbose "Getting the Images with filtered extensions..."
    $Images = Get-ChildItem -Path $FilePath | Where-Object {$_.Extension -in $Extension}

    Write-Output $Images

}

Function Get-FileMetaData {
    [cmdletbinding()]
    Param(
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Alias("Path")]
        [string]$FullName
    )
    $Shell = New-Object -ComObject Shell.Application
    $NameSpace = $Shell.NameSpace((Split-Path $FullName))
    $File = $NameSpace.ParseName((Split-Path $FullName -Leaf))

    $MetaDatas = @()
    for ($i=0; $i  -le 266; $i++) {
        $MetaDataProperties = @{}
        $MetaDataProperties.Integer = $i
        $MetaDataProperties.Name = $($NameSpace.getDetailsOf($NameSpace.items, $i))
        $MetaDataProperties.Value = $($NameSpace.getDetailsOf($File, $i))
        $MetaData = New-Object -TypeName PSObject –Prop $MetaDataProperties
        $MetaData.pstypenames.insert(0,'Custom.PictureToolbox.FileMetaData')
        $MetaDatas += $MetaData
    }
    Write-Output $MetaDatas
}

Function Get-MostExplicitPictureDate {
    <# 
        .SYNOPSIS
        Gets the picture date from the filename or metadata

        .DESCRIPTION
        Tries to get the most explicit picture date from the original file names or metadata

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
      [ValidateScript({ $_.PSObject.TypeNames[0] -eq 'Custom.PictureToolbox.FileMetaData' })]
       $FileMetaData
    )
   

    $FileName 		= $FileMetaData | Where-Object { $_.Integer -eq 0 } | Select-Object -ExpandProperty Value  # 0 = Name
    $DateModified 	= $FileMetaData | Where-Object { $_.Integer -eq 3 } | Select-Object -ExpandProperty Value  # 3 = Date modified
    $DateTaken 		= $FileMetaData | Where-Object { $_.Integer -eq 12 } | Select-Object -ExpandProperty Value # 12 = Date taken

    $DateModified 	= $DateModified -replace '[^a-zA-Z0-9\/: ]', ''
    $DateTaken  	= $DateTaken -replace '[^a-zA-Z0-9\/: ]', ''

    Write-Verbose "Get most explicit date for '$FileName'"
    <# 
        Get most explicit date priority
            1. Based on filename
            2. Date Taken (timestamp from device)
            3. Last Modified Date

        $FileName Example Formats 
            $FileName = "2014-02-14 16.55.30.jpg"
            $FileName = "20140211132236-2160.jpg"
            $FileName = "20140305091538-2-2160.jpg"
            $FileName = "IMG_20151209_103251.jpg"
            $FileName = "IMGD2014-02-14 16.55.30.jpg"
            $FileName = "20140211132236-2160.jpg"
            $FileName = "x.jpg"

    #>    

    $sDate = ""
    $RegexDateFormat1 			= "(\d{4}-\d{2}-\d{2} \d{2}.\d{2}.\d{2})"
    $RegexDateFormat2 			= "(\d{4}\d{2}\d{2}\d{2}\d{2}\d{2})"
    $RegexDateFormat3 			= "(\d{4}\d{2}\d{2}_\d{2}\d{2}\d{2})"
    $RegexDateFormatDateTaken 	= "(\d{2}\/\d{2}\/\d{4} \d{2}:\d{2})"
    
    # Get the most explicit date
    if ($FileName -match $RegexDateFormat1) {
        Write-Verbose "FileName '$FileName' has matched regex format 1 '$RegexDateFormat1'!"
        $Date = $FileName -split $RegexDateFormat1
        $sDate = $Date[1] 
        $sDate = $sDate.Replace(" ","T")
        $sDate = $sDate.Replace(".",":")
    }elseif($FileName -match $RegexDateFormat2) {
        Write-Verbose "FileName '$FileName' has matched regex format 2 '$RegexDateFormat2'!"
        $Date = $FileName -split $RegexDateFormat2
        $sDate = $Date[1] 
        $sDate = $sDate.Insert(4,'-').Insert(7,'-').Insert(10,'T').Insert(13,':').Insert(16,':')
    }elseif($FileName -match $RegexDateFormat3) {
        Write-Verbose "FileName '$FileName' has matched regex format 3 '$RegexDateFormat3'!"
        $Date = $FileName -split $RegexDateFormat3
        $sDate = $Date[1] 
        $sDate = $sDate.Replace("_","T")
        $sDate = $sDate.Insert(4,'-').Insert(7,'-').Insert(13,':').Insert(16,':')
    }elseif($DateTaken -match $RegexDateFormatDateTaken){
        Write-Verbose "No match found for FileName '$FileName', will take the Date Taken '$DateTaken'!"
        $Date = $DateTaken -split $RegexDateFormatDateTaken
        $sDate = $Date
        $sDate = "$($sDate.Substring(4,4))-$($sDate.Substring(2,2))-$($sDate.Substring(0,2))T$($sDate.Substring(9,2)):$($sDate.Substring(12,2)):00"
    }else{
        $Date = $DateModified #-split $RegexDateFormatDateTaken
        $sDate = $Date
        $sDate = "$($sDate.Substring(4,4))-$($sDate.Substring(2,2))-$($sDate.Substring(0,2))T$($sDate.Substring(9,2)):$($sDate.Substring(12,2)):00"
    }        
    
    if ((Test-DateTimePattern -String $sDate -Pattern s -ErrorAction Ignore) -and $sDate) {
        $DateTime 					= [datetime]$sDate 
        Write-Output $DateTime
    }
        
}

Function Test-DateTimePattern {
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

Function Copy-Picture {
    <# 
        .SYNOPSIS
        Copy the picture 

        .DESCRIPTION
        Td

        .PARAMETER FullName
        d

        .PARAMETER Destination
        d

        .EXAMPLE

  
        .OUTPUTS


        .LINK


        .NOTES

    
    #>
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true,  Position=0)]
        [string]$FullName,

        [Parameter(Mandatory=$true,  Position=1)]
        [string]$Destination
        
    )
    if ((Get-Item -Path $FullName).PSIsContainer) {
        Write-Error "Parameter FullName '$FullName' is a container. It should be a file!"
    }
    if (!(Get-Item -Path $Destination).PSIsContainer) {
        Write-Error "Parameter Destination '$Destination' is a file. It should be a container!"
    }

    Write-Verbose "Getting MetaData, FileHash and MostExplicitPictureDate from '$FullName'."
    $ImageMetaDatas = Get-FileMetaData -FullName $FullName
    $ImageMD5sum = Get-FileHash -Path $FullName -Algorithm MD5
    $ImageExplicitDate = Get-MostExplicitPictureDate -FileMetaData $ImageMetaDatas 
    $ImageFileName = (Get-Item -Path $FullName).BaseName
    $ImageExtension = (Get-Item -Path $FullName).Extension

    $Year 	= $ImageExplicitDate.Year
    $Month 	= "0$($ImageExplicitDate.Month)";
    $Month 	= $Month.Substring($Month.length - 2, 2);

    $DestinationFolder = "$Destination\$Year\$Month"

    Write-Verbose "Checking if destination folder '$DestinationFolder' exists."
    if (!(Test-Path $DestinationFolder)) {
        Write-Verbose "Destination folder '$DestinationFolder' does not exist, creating new folder."
        New-Item -Path $DestinationFolder -Force -ItemType Directory
    }


    $DestinationBaseName = "$($ImageExplicitDate.ToString("o").Substring(0,19).Replace(":","."))"

    $i = 0
    $isCopied = $false
    $isDuplicate = $false

    While (!$isCopied -and !$isDuplicate) {
        if ($i -eq 0) {
            $DestinationFilePath = "$Destination\$Year\$Month\$DestinationBaseName$ImageExtension"
        } else {
            $DestinationFilePath = "$Destination\$Year\$Month\$DestinationBaseName-$i$ImageExtension"
        }

        if (!(Test-Path $DestinationFilePath)) {
            Copy-Item -Path $FullName -Destination $DestinationFilePath
            Write-Verbose "File '$FullName' has been copied to '$DestinationFilePath'."
            $isCopied = $true
        } else {
            $DestinationMD5sum = Get-FileHash -Path $DestinationFilePath -Algorithm MD5
            if ($ImageMD5sum.Hash -eq $DestinationMD5sum.Hash) {
                Write-Verbose "Hash '$($ImageMD5sum.Hash)' are identical for both files. File '$FullName' and destination file'$DestinationFilePath' are duplicates."
                $isDuplicate = $true
            }
        }

        $i++

    }
    
}
