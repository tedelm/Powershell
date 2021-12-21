#First fetch session from google chrome (F12 -> Network -> <right click the page document> -> Copy as Powershell)
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36"
$session.Cookies.Add((New-Object System.Net.Cookie("session", "dsfsfsdfsdfsdfsdfsdfsfsdfsdfsfdsdfsdf.2reMeeiZRPKdnSPgiiwd06eR5IQ", "/", "2021.kcahatnas.xyz")))
Invoke-WebRequest -UseBasicParsing -Uri "https://2021.kcahatnas.xyz/challenges" `
-WebSession $session `
-Headers @{
"Cache-Control"="max-age=0"
  "sec-ch-ua"="`" Not A;Brand`";v=`"99`", `"Chromium`";v=`"96`", `"Google Chrome`";v=`"96`""
  "sec-ch-ua-mobile"="?0"
  "sec-ch-ua-platform"="`"Windows`""
  "Upgrade-Insecure-Requests"="1"
  "Accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
  "Sec-Fetch-Site"="none"
  "Sec-Fetch-Mode"="navigate"
  "Sec-Fetch-User"="?1"
  "Sec-Fetch-Dest"="document"
  "Accept-Encoding"="gzip, deflate, br"
  "Accept-Language"="sv-SE,sv;q=0.9"
}

$iwr = Invoke-WebRequest -Uri 'www.exampleurl.com' -WebSession $session
$iwr

#Get all pages
$sitePages = @(
    "https://2021.kcahatnas.xyz/users?page=1"
    "https://2021.kcahatnas.xyz/users?page=2"
    "https://2021.kcahatnas.xyz/users?page=3"
)

#Loop thru all pages
$getElements_UsersArray =@()
foreach ($page in $sitePages) {
    $page
    $Users = Invoke-WebRequest $page -WebSession $session
    $getElements_UsersArray += (($Users.ParsedHtml.getElementsByTagName("tr") | Where {$_.innerHTML -like "*user*"}).innerHTML).Split("<")| Select-String -Pattern "users"
}

#Get user data
$array = @()
$array += "UserName;UserPoints;TeamPoints;Placement;TeamName"

foreach ($UserInfo in $getElements_UsersArray) {
    $User = $UserInfo -split ">"
    $UserUrl = $User[0] -replace "A href=","" -replace '"',""
    $UserAlias = $User[1]
    Write-Host "$UserUrl / $UserAlias"
    $UserUrlFull = "https://2021.kcahatnas.xyz"+$UserUrl
    $UserUrlFull

    $User = Invoke-WebRequest $UserUrlFull -WebSession $session
    $UserName = ($User.ParsedHtml.getElementsByTagName("h1") | Where {$_.scopeName -eq "HTML"}).innerText
    $UserPoints = ($User.ParsedHtml.getElementsByTagName("h2") | Where {$_.className -eq "text-center"}).innerText
    $TeamName = ($User.ParsedHtml.getElementsByTagName("span") | Where {$_.className -eq "badge badge-secondary"}).innerText

            
    $PointsArray =@()
    #$PointsArray = ($User.ParsedHtml.getElementsByTagName("td") | ?{$_.outerText -match "[0-9][0-9][0-9]"}).outerText
    $PointsArray = ($User.ParsedHtml.getElementsByTagName("td") | ?{$_.outerText -match "\d"}).outerText
    $Points = 0
    foreach ($Point in $PointsArray) {
        $Points += [int]$Point
    }

    $array += "$UserName;$Points;$(($UserPoints[1]) -replace ' points','' );$($UserPoints[0]);$TeamName"
}

$array

