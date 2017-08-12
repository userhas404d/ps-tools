function get-DTA($folder){

try{
    Test-Path $folder
}
catch{
    write-host "file path is not valid, exiting.."
    break
}

$foldercontents = Get-ChildItem $folder -Recurse -File
$output = @()

foreach ($item in $foldercontents){
    $output += New-Object -TypeName PSObject -Property @{
                TodaysDate = Get-Date -Format d
                User = $env:USERNAME
                FileName = $item.Name
                Kb = ("{0:N0}" -f ($item.Length/ 1Kb))
    } | Select-Object TodaysDate,User,FileName,Kb
}

$output

}
