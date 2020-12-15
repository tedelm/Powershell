<#
 . .\PS-IWR-Download-FalcoX.ps1
Invoke-DownloadFalcoX -Alpha -Folder "~\Desktop\Firmware\FlightOne"
Invoke-DownloadFalcoX -Beta -Folder "~\Desktop\Firmware\FlightOne"
Invoke-DownloadFalcoX -Stable -Folder "~\Desktop\Drone\Firmware\FlightOne"
#>



function Invoke-DownloadFalcoX(){
    param (
        [Switch]$Alpha,
        [Switch]$Beta,
        [Switch]$Stable,
        [String]$Folder
    )


if($Alpha){$MainLink = "https://flightone.com/download.php?version=alpha";$VersionFolder = "Alpha"}
if($Beta){$MainLink = "https://flightone.com/download.php?version=beta";$VersionFolder = "Beta"}
if($Stable){$MainLink = "https://flightone.com/download.php?version=stable";$VersionFolder = "Stable"}

$DownloadFolder = $Folder

Write-Host "Collecting download links" -BackgroundColor "Blue" -ForegroundColor "Yellow"

$IWR = Invoke-WebRequest $MainLink
$DLLink = ($IWR.Links | ?{$_.href -like "*/firmware/*"}).href

Foreach ($Link in $DLLink) {
    
    $Link = "https://flightone.com" + $Link
    Write-Host "Found: $Link" -BackgroundColor "Green" -ForegroundColor "Black"

    $FWfile = $Link.split("/")[5]
    
    if($FWfile -like "*.flx"){

        $DLFolder = $FWfile.split("_")[1]


        if($FWfile -like "*"){$Output = $DownloadFolder +"\$VersionFolder\$DLFolder\"}
        if($FWfile -like "*LIGHTNING*"){$Output = $DownloadFolder +"\Lightning H7 - $VersionFolder\$DLFolder\"}
       
        #Create folder if missing
        if(!$(Test-Path $Output)){Write-Host "Directory does not exist, creating: $($Output.split('\')[8])";New-Item -ItemType "directory" $Output | out-null}

        Write-Host "Found fw: $FWfile" -BackgroundColor "Green" -ForegroundColor "Black"

        #Check if already downloaded
        if(!$(Test-Path (Join-path $Output $FWfile)) ){
            Write-Host "Downloading:  $FWfile" -BackgroundColor "Green" -ForegroundColor "Black"
            Start-BitsTransfer -Source $Link -Destination $output            
        }else{
            Write-Host "Firmware already downloaded: $FWfile"
        }

    }elseif($Link -match "/firmware/beta/"){
        Write-Host "No .flx link on page" -BackgroundColor "Red" -ForegroundColor "Yellow"
    }else{
        Write-Host "No .flx file found" -BackgroundColor "Red" -ForegroundColor "Yellow"
    }

}

}