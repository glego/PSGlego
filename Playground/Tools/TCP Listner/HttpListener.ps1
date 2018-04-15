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
        if ($rawParameters) {
            $rawParameters = $rawParameters.Split("&")
        

            foreach ($rawParameter in $rawParameters) {
                $Parameter = $rawParameter.Split("=")

                $Parameters.Add($Parameter[0], $Parameter[1])
            }al
        }

        # Create output string (dirty html)
        $output = "<html><body><p>"
        $output = $output + "Path is $Path" + "<br />"
        foreach ($Parameter in $Parameters.GetEnumerator()) {
            $output = $output + "$($Parameter.Name) is equal to $($Parameter.Value)" + "<br />"
        }

        $output = $output + "</p></body></html>"
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