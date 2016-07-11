
####################################################################################
## This script works for a clustered Data ONTAP storage system. 
## It creates a VLAN id for every nodes of a cDOT and the associated broadcast domain.
## 
## Author: Pablo Garcia Arevalo
####################################################################################

# Runtime variables
$clusterName = "mycDOT"
$clusterIP = "192.168.0.5"
$port = "a0a"
$mtu = "1500"
$vlanID = "11"


# Connect to destination cluster
Write-Host "Connecting to cluster $clusterName ... " -NoNewLine
$conn = Connect-NcController -Name $clusterIP -HTTPS
if ($conn -eq $null)
    {
    Write-Host "Connection to host $clusterName failed!" -foregroundcolor "red"
    break
    }
else {
    Write-Host "Done." -foregroundcolor "green"
}

New-NcNetPortBroadcastDomain -Name "vlan-$vlanID" -Ipspace Default -Mtu $mtu

foreach ($node in Get-NcClusterNode ) {

    $nodeName = $node | select NodeName | ft -hide | out-string
    $nodeName = $NodeName.Trim()
    New-NcNetPortVlan $port $nodeName -VlanId $vlanID
    Set-NcNetPortBroadcastDomain -Name "vlan-$vlanID" -AddPort "$nodeName`:$port-$vlanID"
    }



