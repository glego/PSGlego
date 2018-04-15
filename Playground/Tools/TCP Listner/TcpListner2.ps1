# http://localhost:5566
# http://localhost:5566/test.html?parameter1=xxx&parameter2=yyy

#$listener = [System.Net.Sockets.TcpListener]5566;
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:5566/")


try {
    $listener.Start();
    while ($true) {   
        $context = $listener.GetContext()
        $request = $context.Request

        # Output the request to host
        Write-Host $request | fl * | Out-String

        # Parse Parameters from url
        $rawUrl = $request.RawUrl

        $Parameters = @{}
        $rawUrl = $rawUrl.Split("?")
        $Path = $rawUrl[0]
        $rawParameters = $rawUrl[1]
        $rawParameters = $rawParameters.Split("&")
        $output = ""

        foreach ($rawParameter in $rawParameters) {
            $Parameter = $rawParameter.Split("=")
    
            $Parameters.Add($Parameter[0], $Parameter[1])
        }

        # Create output string (dirty html)
        $output = $output + "Path is $Path" + "<br />"
        foreach ($Parameter in $Parameters.GetEnumerator()) {
            $output = $output + "$($Parameter.Name) is equal to $($Parameter.Value)" + "<br />"
        }
        
        # Send response
        $statusCode = 200
        $response = $context.Response
        $response.StatusCode = $statusCode    
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($output)
        $response.ContentLength64 = $buffer.Length
        $output = $response.OutputStream
        $output.Write($buffer,0,$buffer.Length)
        $output.Close()
    }
} finally {
    $listener.Stop()
}
