function Get-splTransfers {
    param (
        [String]$Token
    )
    $Headers = @{
        accept = 'application/json'
    }

    $Url = 'https://public-api.solscan.io/account/transactions?account='+$Token
    $Response = Invoke-RestMethod -Uri $Url -Method Get

    foreach ($item in $Response) {
       
       $Url = 'https://public-api.solscan.io/transaction/'+$($item.txHash)
       #$Url
       $Response = Invoke-RestMethod -Uri $Url -Method Get
       #$($Response.tokenTransfers)
       Write-Host ' '
       Write-Host 'Transaction: ' $($item.txHash)
       Write-Host 'Source_Owner: ' $($Response.tokenTransfers.source_owner)
       Write-Host 'Destination_Owner: ' $($Response.tokenTransfers.destination_owner)
    }

    #return $Response
    
}

Get-splTransfers -Token <token>


