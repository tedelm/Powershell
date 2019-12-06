<#
.SYNOPSIS
Search Azure AD with Graph API

.DESCRIPTION
Setup:
1. Load script/functions by running ". .\PS-O365-GraphWithCertificateAuthJWT.ps1"
2. Create a self-signed certificate by running: "CreateNewCertificate -CertificateFriendlyName application1.company.com -TenantName company.onmicrosoft.com"
3. Take note of the certificate Thumbprint
4. Upload public part of certificate "C:\users\$env:USERNAME\Desktop\$CertificateFriendlyName.cer" to Azure Application Registration (Certificates and Secrets)
5. In Azure AD, add "API permissions" to the registered application "Directory.Read.All", "Group.Read.All", "GroupMember.Read.All", "User.Read", "User.Read.All"
6. In Azure AD, add "API permissions": "Grant admin consent for <customer>"


.NOTES
Author
Ted Elmenheim
Created: 2019-12-06
Edited: 
2019-12-06 - Added support for certificate creation

Search Tags: Azure AD, Graph, API, Manager


.EXAMPLE
Load script/functions by running ". .\PS-O365-GraphWithCertificateAuthJWT.ps1"
Add connection settings: SetConnectionParams -AzureTenantName "customer.onmicrosoft.com" -AzureAppId "2345ksdf-r4345-4453-sdf3-elk45292534" -AzureCertificateTumbprint ccc77da9dd227565o0fc79f60340bb1e1a4a5b4
Run "Get"-functions:
    * GetUsers -userPrincipalName <user@company.onmicrosoft.com>
    * GetManager -userPrincipalName <user@company.onmicrosoft.com>
    * GetAllManagers

.LINK

#>

#SetConnectionParams - Use this to set connection variables
Function SetConnectionParams($AzureTenantName, $AzureAppId, $AzureCertificateTumbprint){
    #Azure AD Tenant
    $Global:TenantName_ = $AzureTenantName
    #Application ID in Azure
    $Global:AppId_ = $AzureAppId
    #My certificate (Private key)
    $Global:Certificate_ = Get-Item Cert:\CurrentUser\My\$($AzureCertificateTumbprint)

}

#Create SSL certificate
Function CreateNewCertificate($CertificateFriendlyName, $TenantName){

    # Where to export the certificate without the private key
    $CerOutputPath     = "C:\users\$env:USERNAME\Desktop\$CertificateFriendlyName.cer"
    # What cert store you want it to be in
    $StoreLocation     = "Cert:\CurrentUser\My"

    $CreateCertificateSplat = @{
        Subject             = "CN=$CertificateFriendlyName"
        DnsName             = $TenantName
        FriendlyName        = $CertificateFriendlyName
        NotAfter            = $((Get-Date).AddYears(5))
        CertStoreLocation   = "Cert:\CurrentUser\My"
        KeyExportPolicy     = "Exportable"
        KeySpec             = "Signature"
        KeyLength           = "2048"
        KeyAlgorithm        = "RSA"
        Provider            = "Microsoft Enhanced RSA and AES Cryptographic Provider"
        HashAlgorithm       = "SHA256"
        }
        
    # Create certificate
    $Certificate = New-SelfSignedCertificate @CreateCertificateSplat

# Get certificate path
$CertificatePath = Join-Path -Path $StoreLocation -ChildPath $Certificate.Thumbprint
# Export certificate without private key    
Export-Certificate -Cert $CertificatePath -FilePath $CerOutputPath | Out-Null
Write-host "Certificate exported to: $CerOutputPath"
Write-Host "Tumbprint: $($Certificate.Thumbprint)"

}

#Create Accesstoken - valid for 2min
Function CreateAccessToken($TenantName,$AppId,$Certificate){
$Scope = "https://graph.microsoft.com/.default"
# Create base64 hash of certificate
$CertificateBase64Hash = [System.Convert]::ToBase64String($Certificate.GetCertHash())

# Create JWT timestamp for expiration
$StartDate = (Get-Date "1970-01-01T00:00:00Z" ).ToUniversalTime()
$JWTExpirationTimeSpan = (New-TimeSpan -Start $StartDate -End (Get-Date).ToUniversalTime().AddMinutes(2)).TotalSeconds
$JWTExpiration = [math]::Round($JWTExpirationTimeSpan,0)

# Create JWT validity start timestamp
$NotBeforeExpirationTimeSpan = (New-TimeSpan -Start $StartDate -End ((Get-Date).ToUniversalTime())).TotalSeconds
$NotBefore = [math]::Round($NotBeforeExpirationTimeSpan,0)

# Create JWT header
$JWTHeader = @{
    alg = "RS256"
    typ = "JWT"
    # Use the CertificateBase64Hash and replace/strip to match web encoding of base64
    x5t = $CertificateBase64Hash -replace '\+','-' -replace '/','_' -replace '='
}

# Create JWT payload
$JWTPayLoad = @{
    # What endpoint is allowed to use this JWT
    aud = "https://login.microsoftonline.com/$TenantName/oauth2/token"
    # Expiration timestamp
    exp = $JWTExpiration
    # Issuer = your application
    iss = $AppId
    # JWT ID: random guid
    jti = [guid]::NewGuid()
    # Not to be used before
    nbf = $NotBefore
    # JWT Subject
    sub = $AppId
}

# Convert header and payload to base64
$JWTHeaderToByte = [System.Text.Encoding]::UTF8.GetBytes(($JWTHeader | ConvertTo-Json))
$EncodedHeader = [System.Convert]::ToBase64String($JWTHeaderToByte)
$JWTPayLoadToByte =  [System.Text.Encoding]::UTF8.GetBytes(($JWTPayload | ConvertTo-Json))
$EncodedPayload = [System.Convert]::ToBase64String($JWTPayLoadToByte)
# Join header and Payload with "." to create a valid (unsigned) JWT
$JWT = $EncodedHeader + "." + $EncodedPayload
# Get the private key object of your certificate
$PrivateKey = $Certificate.PrivateKey
# Define RSA signature and hashing algorithm
$RSAPadding = [Security.Cryptography.RSASignaturePadding]::Pkcs1
$HashAlgorithm = [Security.Cryptography.HashAlgorithmName]::SHA256
# Create a signature of the JWT
$Signature = [Convert]::ToBase64String(
    $PrivateKey.SignData([System.Text.Encoding]::UTF8.GetBytes($JWT),$HashAlgorithm,$RSAPadding)
) -replace '\+','-' -replace '/','_' -replace '='

# Join the signature to the JWT with "."
$JWT = $JWT + "." + $Signature
# Create a hash with body parameters
$Body = @{
    client_id = $AppId
    client_assertion = $JWT
    client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
    scope = $Scope
    grant_type = "client_credentials"
}

$Url = "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token"
# Use the self-generated JWT as Authorization
$Header = @{
    Authorization = "Bearer $JWT"
}
# Splat the parameters for Invoke-Restmethod for cleaner code
$PostSplat = @{
    ContentType = 'application/x-www-form-urlencoded'
    Method = 'POST'
    Body = $Body
    Uri = $Url
    Headers = $Header
}

#Save token in session
$script:Request = Invoke-RestMethod @PostSplat

}



#GetUsers - Get all or specific user
Function GetUsers($userPrincipalName, $Id){
    #Get AccessToken
    CreateAccessToken -TenantName $TenantName_ -AppId $AppId_ -Certificate $Certificate_
    $QuestionResult =@()
    # Create header
    $Header = @{
        Authorization = "$($Request.token_type) $($Request.access_token)"
    }

    If($userPrincipalName){
        $Uri = "https://graph.microsoft.com/v1.0/users/$userPrincipalName"
    }elseif($Id){
        $Uri = "https://graph.microsoft.com/v1.0/users/$Id"
    }else{
        $Uri = [string]$Uri = 'https://graph.microsoft.com/v1.0/users/?$top=999'
    }

#        $Question_ = Invoke-RestMethod -Uri $Uri -Headers $Header -Method Get -ContentType "application/json" -ErrorAction SilentlyContinue
    $Question_ = try{
        Invoke-RestMethod -Uri $Uri -Headers $Header -Method Get -ContentType "application/json" -ErrorAction SilentlyContinue
    }catch{
        Continue
    }

    if(!$Question_){
    #Get AccessToken
    CreateAccessToken -TenantName $TenantName_ -AppId $AppId_ -Certificate $Certificate_
    $Question_ = try{Invoke-RestMethod -Uri $Uri -Headers $Header -Method Get -ContentType "application/json" -ErrorAction SilentlyContinue
    }catch{
        Continue
    }
    }

    If($($Question_.Value)){
        $QuestionResult += $Question_.Value
    }Else{
        $QuestionResult += $Question_
    }

$QuestionResult
}


#GetManager - Get specific users Manager
Function GetManager($userPrincipalName){


    $QuestionResult =@()
    # Create header
    $Header = @{
        Authorization = "$($Request.token_type) $($Request.access_token)"
    }

    $Uri = "https://graph.microsoft.com/v1.0/users/$($userPrincipalName)/manager"

    
    # Fetch all security alerts
    $Question_ = try{
                        Invoke-RestMethod -Uri $Uri -Headers $Header -Method Get -ContentType "application/json" -ErrorAction SilentlyContinue
                }catch{
                        Continue
                }

    if(!$Question_){
        #Get AccessToken
        CreateAccessToken -TenantName $TenantName_ -AppId $AppId_ -Certificate $Certificate_
            # Create header
            $Header = @{
                Authorization = "$($Request.token_type) $($Request.access_token)"
            }        
        $Question_ = try{Invoke-RestMethod -Uri $Uri -Headers $Header -Method Get -ContentType "application/json" -ErrorAction SilentlyContinue
                    }catch{
                         Continue
                    }
    } 

    Write-host "Requested URL: $Uri"
    $QuestionResult += $Question_
    $QuestionResult
}

#GetAllManagers - Get all users manager
Function GetAllManagers(){
    #Create Table object
    $script:table = New-Object system.Data.DataTable “PSMyTable”
    #Define Columns
    $col1 = New-Object system.Data.DataColumn UPN,([string])
    $col2 = New-Object system.Data.DataColumn Manager,([string])
    #Add the Columns
    $table.columns.add($col1)
    $table.columns.add($col2)    

        Foreach($user in $(GetUsers)){
            $manager = (GetManager -userPrincipalName $($user.userprincipalname) -ErrorAction SilentlyContinue).userPrincipalName

            if($manager){
            "$UPN   $($user.userprincipalname)"


            #Create a row
            $row = $table.NewRow()

            #Enter data in the row
            $row.UPN = $($user.userprincipalname)
            $row.Manager = $manager

            #Add the row to the table
            $table.Rows.Add($row)
            }

        }

$table | sort manager

}


