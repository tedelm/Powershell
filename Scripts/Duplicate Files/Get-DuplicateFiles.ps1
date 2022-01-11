
function Get-DuplicateFiles {
    param (
        [String]$FilePath,
        [Switch]$DeleteDuplicate
    )

    $result =@()
    $fileToDelete =@()

    $files = Get-ChildItem -Path $FilePath -Recurse | select Fullname,@{Label="Hash";Expression={( (Get-FileHash -Path "$($_.fullname)" -Algorithm MD5).hash ) }}
    $duplicates_hashes = ($files | group hash -NoElement | where -Property count -gt 1).name
    

    foreach ($hash in $duplicates_hashes) {
        $subRes = $files | where -Property hash -Contains $hash
        $result += $subRes
        $fileToDelete += $subRes | select -skip 1
    }

    if(!$fileToDelete){
        $files
        Write-host "No duplicates found" -ForegroundColor Blue -BackgroundColor Yellow
    }else{
        if($DeleteDuplicate){

            $readHost = Read-Host "Do you want to delete duplicate files? [y/n]"
    
            if($readHost -match "y"){
                foreach ($file in $fileToDelete) {
                    Write-host -ForegroundColor Red -BackgroundColor Yellow "Deleting '$($file.FullName)' (Hash: '$($file.Hash)')" 
                    Remove-Item -Path $($file.FullName)
                    
                }
            }
    
        }
    }

}

Get-DuplicateFiles -Filepath C:\PowershellTest -DeleteDuplicate


