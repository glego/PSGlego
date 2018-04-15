#$listener = [System.Net.Sockets.TcpListener]5566;
$listener = New-Object System.Net.HttpListener

$listener.Start();

while ($true) {
    #$client = $Listener.AcceptTcpClient();
    $context = $listener.GetContext()
    $request = $context.Request
    Write-Host "Connected!";
    Write-Host $context
    Write-Host $request

    $client.Close();
}