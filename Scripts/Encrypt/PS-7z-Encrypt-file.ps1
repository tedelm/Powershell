

function Encrypt-File(){
    param (
        [string]$Source,
        [string]$Destination,
        [string]$Password
    )
    
    C:\Tools\7-ZipPortable\App\7-Zip\7z.exe a "$($Destination)" "$($Source)" -p"$($Password)"
}

Encrypt-File -Source .\Logfile2.txt -Destination .\Logfile2.enc -Password "Password"