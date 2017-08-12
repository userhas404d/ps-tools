Connect-VIServer -Server CHANGEME -user CHANGEME

$folderToRecreate= Get-Folder -Name Master
$Anchor = Get-Folder -Name Clones

$destDataStore = "10k SAS drives"
$refSnap = "Clone Snapshot"

# Name of VM to clone (will be base/parent of linked clone
$SrcVmName = get-vm -Location Master 
       
#create snapshots for master vms
foreach($name in $SrcVmName){ 
 
# Create snapshot to create linked clones from
$SrcVmSnap = New-Snapshot -VM $name -Name $refSnap -Quiesce:$true -Confirm:$false -RunAsync

}

#create linked clones from newly created snapshot on Master vms
foreach($name in $SrcVmName){

$NewVmName = "clone_$name"

$CloneVM = New-VM -Name $NewVmName -VM $name -Location $Anchor  -Datastore $destDataStore -ResourcePool Resources -LinkedClone -ReferenceSnapshot $refSnap -RunAsync

}

#copy folder structure from Master to Clones
#modified from here: https://psvmware.wordpress.com/tag/powercli-copy-folder-structure-between-virtual-center-servers/
function Copy-VCFolderStructure {

   param(
   [parameter(Mandatory = $true)]
   [ValidateNotNullOrEmpty()]
   [VMware.Vim.Folder]$OldFolder,
   [parameter(Mandatory = $true)]
   [ValidateNotNullOrEmpty()]
   [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl]$ParentOfNewFolder
      )
  $NewFolder = New-Folder -Location $ParentOfNewFolder -Name $OldFolder.Name
  Get-VM -NoRecursion -Location ($OldFolder|Get-VIObjectByVIView)|Select-Object Name, @{N='Folder';E={$NewFolder.id}}
  foreach ($childfolder in $OldFolder.ChildEntity|Where-Object {$_.type -eq 'Folder'})
                  {
                   Copy-VCFolderStructure -OldFolder (Get-View -Id $ChildFolder) -ParentOfNewFolder $NewFolder
                  }
}

$vmlist = Copy-VCFolderStructure -OldFolder $folderToRecreate.extensiondata -ParentOfNewFolder $Anchor

foreach($vm in $vmlist) {
    
  move-vm -vm ("clone_"+$vm.Name) -destination (get-view -id $vm.folder|get-viobjectbyviview)
    
}



<#

#remove clones and new folders

$ClonedVmName = get-vm -Location Clones 
Remove-VM -DeletePermanently $ClonedVmName -Confirm:$false
Get-Snapshot $SrcVmName | Remove-Snapshot -Confirm:$false -RunAsync
Get-Folder -Location Clones -Name Master | Remove-Folder -Confirm:$false

#>
