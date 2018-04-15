
# Get text after last digits
$MyString = "01baaab01blah02baboon"

$Result = [regex]::matches($MyString, "\D+")
$LastResult = $Result[$Result.Count-1].Value
Write-Output "My last result = $LastResult"
