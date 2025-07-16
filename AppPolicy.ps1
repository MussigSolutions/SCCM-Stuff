<#
  Title:
  Stale App Policy Fix

  Error:
  0x87D00314 - CI Version Info timed out
  
  Description:
  Resolves instances where client's have not received software updates or are missing assigned collections.
  Normally identifiable by applications reporting an applicability state of unknown and a current state of error.
  The applications may also not be present in WMI or the endpoint's client.
  
  Problem devices in our environment were unable to be resolved with mach pol and evaluation cycles, repairing the client, or re-installing the client.

  
  References:
  https://learn.microsoft.com/en-us/intune/configmgr/develop/reference/core/clients/sdk/ccm_applicationpolicy-client-wmi-class
  https://learn.microsoft.com/en-us/intune/configmgr/tenant-attach/app-install-error-reference#0x87d00314
  https://learn.microsoft.com/en-us/archive/msdn-technet-forums/8f54f591-073a-49b5-b433-cd6a0947a13a#64aaa052-15fa-414d-8590-58e270e00b00
  
#>
$Device = Read-Host "Enter the hostname"
$Session = new-cimsession -ComputerName $Device -SessionOption (New-CimSessionOption -Protocol DCOM)

if($Session){

  $ApplicationPolicy = Get-CimInstance -cimsession $session -Namespace 'ROOT\CCM\ClientSDK' -Query "SELECT * FROM CCM_ApplicationPolicy" | Where {$_.CurrentState -eq 'Error'}
  
  if(!Applicationpolicy){
    Write-host 'No applications reporting an error state.'
  }else{
  
    $PolicyClass = [WmiClass]"\\$Device\root\ccm\clientSDK:CCM_ApplicationPolicy"
  
    foreach($Policy in $ApplicationPolicy){
        $PolicyClass.EvaluateAppPolicy($Policy.Id,$Policy.Revision,$Policy.IsMachineTarget,'High',0)
    }
  }
  
}else{
  Write-host 'Unable to establish a cim session with $Device'
}
