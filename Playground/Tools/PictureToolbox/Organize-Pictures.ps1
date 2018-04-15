<#
.SYNOPSIS
Gets all pictures from a certain directory

.DESCRIPTION
Gets all pictures from a directory with all properties

.PARAMETER directory
The full path of a directory to find pictures.

.PARAMETER pictureExtensions
Picture extentions pictures.

#>

[CmdletBinding()]
Param(
    #[parameter(Mandatory=$true)]
    [string]$directory = "F:\ITXSERVER\DATA1\Pictures\",

    #[parameter(Mandatory=$true)]
    [string[]]$pictureExtensions = @(".jpg"; ".jpeg")

)

$pictures = Get-ChildItem -Path $directory -Recurse | Where-Object { $_.Extension -notin $pictureExtensions -and $_.PSIsContainer -eq $false};

Get-ChildItem -Path $directory -Recurse | 
    ForEach-Object { 
        IF ($_.Extension -in $pictureExtensions -and $_.PSIsContainer -eq $false) {
            
            # Detect Source (Samsung Mobile, Canon, ect..)

            # Get Date (FileName > Date Taken > File Date Modified)
            # FileName Formats: 
            # 2014-02-14 16.55.30.jpg
            # 20140211132236-2160.jpg
            # 20140305091538-2-2160.jp         

        }   
    }

Write-Host "end.."
# Starting Variables
$Today = Get-Date

$outputSuffix = $Today.ToString("yyyMMdd-HHmmss")
$outputName = $outputPrefix + "-" + $outputSuffix

$outputFile7z = $outputDir + $outputName + ".7z"
$logFile7z = $logDir + $outputName + ".7z.log"
$logFilePS = $logDir + $outputName + ".ps.log"

# 7-Zip Compression Levels
#   0: No Compression
#   3: Fast Compression
#   7: Maximum Compression
#   9: Utra Compression
$7zipArgsCompLvl = 0

function 7zipCompress () {
$7zipArgs = @(
    "a";                          # Create an archive.
    "-t7z";                       # Use the 7z format.
    "-mx=$7zipArgsCompLvl";       # Use a level 0 "store" 7 "high" compression.
#    "-xr!thumbs.db";              # Exclude thumbs.db files wherever they are found.
#    "-xr!*.log";                  # Exclude all *.log files as well.
    "-xr-@`"`"$excludesFile`"`""; # Exclude all paths in my excludes.txt file.
    "-ir-@`"`"$includesFile`"`""; # Include all paths in my includes.txt file.
    "$outputFile7z";              # Output file path (a *.7z file).
    "-y";                         # Answers yes to all prompts
#    "-w $tempDir";               # Working Directory
)

# Compress to temporary folder
& $7zip @7zipArgs | Tee-Object -LiteralPath $logFile7z
if ($LASTEXITCODE -gt 1) # Ignores warnings which use exit code 1.
{
    throw "7zip failed with exit code $LASTEXITCODE"
}
}

# Main Script
try
{
    7zipCompress
}
Catch
{
    # catch
    Write-Host "damn error"
}
Finally
{
    # finally
}