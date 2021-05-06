<#

#>


try{
    Write-Host "PSSQLite Module found.. loading"
    Import-Module PSSQLite
}catch{
    Write-Host "PSSQLite Module missing.. Installing"
    Install-Module -Name PSSQLite -Force
}


If( $(Test-path "C:\Users\$($env:username)\AppData\Local\Google\Chrome\User Data\Default\History") ){
    Write-Host "SQLite DB found.. loading"
    $DataSource = "C:\Users\$($env:username)\AppData\Local\Google\Chrome\User Data\Default\History"
}Else{
    Write-Host "SQLite DB not found.. searching" -ForegroundColor yellow
    $DataSource = (Get-ChildItem "C:\Users\$($env:username)\AppData\Local\Google\Chrome\User Data" -Recurse * -Include history | sort LastWriteTime | select -Last 1).FullName

    If($DataSource){
        Write-Host "SQLite DB found.. loading"
    }Else {
        Write-Host "SQLite DB not found..." -ForegroundColor red -backgroundcolor yellow
        $_ = Read-Host "Exit..."
        exit
    }
}

Write-Host "Please close Chrome...if open..." -ForegroundColor red -backgroundcolor yellow
$_ = Read-Host "[Press Enter]"


######### Search Words ##########
function GoogleHistorySearchWords(){
    Write-Host "Loading Search Words" -ForegroundColor blue -backgroundcolor yellow
    $r_kwsts = Invoke-SqliteQuery -Query "SELECT * FROM keyword_search_terms" -DataSource "$($DataSource)"

    $r_kwsts | Group-Object normalized_term | sort count | select count,name

    Write-host "You have searched the internet using $($r_kwsts.count) strings" -ForegroundColor red -backgroundcolor yellow
}
GoogleHistorySearchWords
$_ = Read-Host "[Press Enter]"

######### Urls ##########

function GoogleHistoryUrls(){
    Write-Host "Loading URLs" -ForegroundColor blue -backgroundcolor yellow
    $r_urls = Invoke-SqliteQuery -Query "SELECT * FROM urls" -DataSource "$($DataSource)"
    $r_urls | Group-Object url | sort count | select count,name
    
    Write-host "You have visited $($r_urls.count) sites" -ForegroundColor red -backgroundcolor yellow

}
GoogleHistoryUrls
$_ = Read-Host "[Press Enter]"

######### Downloads ##########
function GoogleHistoryDownloads(){
    Write-Host "Loading Downloads" -ForegroundColor blue -backgroundcolor yellow
    $r_dls = Invoke-SqliteQuery -Query "SELECT * FROM Downloads" -DataSource "$($DataSource)"

    $v_dls = 0
    foreach($r_dl in $r_dls){

        $time = [datetime]::FromFileTime($r_dl.start_time)

        Write-host "[ - - - - - - - - New File - - - - - - - - ]" -ForegroundColor yellow
        Write-host "Last Modified: $($r_dl.last_modified)"
        Write-host "File: $($r_dl.target_path)"
        Write-host "Url: $($r_dl.referrer)"
        Write-host "Url: $($r_dl.tab_url)"
        Start-Sleep -Milliseconds 200

        $v_dls++
    }
    Write-host "You have downloaded $v_dls files" -ForegroundColor red -backgroundcolor yellow
}
GoogleHistoryDownloads
$_ = Read-Host "[Press Enter]"




