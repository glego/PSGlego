﻿
Remove-NetFirewallRule -Name "Rocket League Bad Servers (out)" -ErrorAction SilentlyContinue

New-NetFirewallRule -Name "Rocket League Bad Servers (out)" `
                                        "188.42.188.0-188.42.191.255", 
                                        "31.204.146.0-31.204.146.127",
                                        "109.200.217.128-109.200.217.255")

                  
                    