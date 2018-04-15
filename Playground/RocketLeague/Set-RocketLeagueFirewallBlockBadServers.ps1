
Remove-NetFirewallRule -Name "Rocket League Bad Servers (out)" -ErrorAction SilentlyContinue

New-NetFirewallRule -Name "Rocket League Bad Servers (out)" `                    -Description "Rocket League Servers with bad ping" `                    -DisplayName "Rocket League Bad Servers (out)" `                    -Enabled True `                    -Profile Any `                    -Direction Outbound `                    -Action Block `                    -RemoteAddress ("213.163.80.0-213.163.81.255", 
                                        "188.42.188.0-188.42.191.255", 
                                        "31.204.146.0-31.204.146.127",
                                        "109.200.217.128-109.200.217.255")

                  
                    