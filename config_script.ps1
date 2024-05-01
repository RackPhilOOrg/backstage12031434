# Enable IIS feature
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole

# Start the default website
Start-WebSite -Name 'Default Web Site'

# Allow incoming HTTP traffic through Windows Firewall
New-NetFirewallRule -Name "Allow HTTP" -DisplayName "Allow HTTP" -Protocol TCP -LocalPort 80 -Action Allow

# Allow incoming WinRM traffic through Windows Firewall
New-NetFirewallRule -Name "Allow WinRM" -DisplayName "Allow WinRM" -Protocol TCP -LocalPort 5985 -Action Allow