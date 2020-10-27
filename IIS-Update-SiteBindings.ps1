<#
.SYNOPSIS
    Gets all websites hosted on given IIS server. If Bindings of site are IPAddress specific, script replaces old IPAddress binding with new IPAddress of VM.
    If Bindings of site are generic, script does not replace it.

.DESCRIPTION
    This script should be used in conjuction with IISWebTierUpdate.ps1 runbook. 

.INPUTS
    None.

.OUTPUTS
    System.String Old and new IP address mapping for VM.


.NOTE
    The script is to be run only on Azure classic resources. It is not supported for Azure Resource Manager resources.
    
    Author: sakulkar@microsoft.com

#>

$pathVariable=$env:windir+"\system32\inetsrv"
$result=""

try
{one 
    $sites=Get-Website
    $oldIPGot=$false

    foreach($site in $sites)
    {
        $siteName = $site.Name
        $bindings = Get-WebBinding -Name $siteName
        $newIPAddress = (get-netadapter | get-netipaddress | ? addressfamily -eq 'IPv4').ipaddress
        $oldBindingInformation = $bindings.bindingInformation
        $temp = $oldBindingInformation
        $oldIpAddress = $temp.Split(":")[0]

        if(!$oldIpAddress.Equals("*"))
        {
            if(!$oldIPGot)
            {
                $oldIPGot=$true
                $result=$oldIpAddress+","+$newIPAddress
            }
            Set-WebBinding -Name $siteName -BindingInformation $oldBindingInformation -PropertyName IPAddress -Value $newIPAddress -ErrorAction Stop
        }
    }
    $result
}
catch
{
    $ErrorMessage = "Unable to update binding information. Exception:"
    $ErrorMessage = $ErrorMessage+$_.Exception.Message

    throw($ErrorMessage)
}