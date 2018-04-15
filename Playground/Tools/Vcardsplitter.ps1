clear-host
$ifile = $args[0]
If( $ifile -eq $NULL )
{
Write-Host Usage: .\vcfrw.ps1 filename.vcf
Exit
}
Write-Host Processing Lotus Notes vCard File: $ifile

$i = 1
switch -regex -file $ifile
{
"^BEGIN:VCARD" {if($FString){$FString |
out-file -Encoding "ASCII" "$ifile.$i.vcf"};$FString = $_;$i++}
"^(?!BEGIN:VCARD)" {$FString+="`r`n$_"}
}

Write-Host VCard Processing Complete
Write-Host Processed $i VCard entries 