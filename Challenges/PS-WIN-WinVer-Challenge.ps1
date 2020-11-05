<#
.SYNOPSIS
Get or Set Winver Organizational settings

.DESCRIPTION
Use this script to Get or Set Winver registered owner or registered org

Name: PS-Win-WinVer-Challenge.ps1
Author: Ted.elmenheim@gmail.com
Created: 2020-11-04

.EXAMPLE
#Load script
. .\PS-Win-WinVer-Challenge.ps1

#Get local WinVer settings
GetWinVerRegistrationSettings

#Get remote computer WinVer settings
GetWinVerRegistrationSettings -RegisteredOwner <user> -RegisteredOrganization <org> -ComputerName <remotecomputer>

#Get remote computer WinVer settings with array
$arrayOfservers | foreach{ GetWinVerRegistrationSettings }

#Set local WinVer settings
SetWinVerRegistrationSettings -RegisteredOwner <user> -RegisteredOrganization <org>

#Set remote computer WinVer settings
SetWinVerRegistrationSettings -RegisteredOwner <user> -RegisteredOrganization <org> -ComputerName <remotecomputer>

#Set remote computer WinVer settings with array
$arrayOfservers | foreach{ SetWinVerRegistrationSettings -RegisteredOwner <user> -RegisteredOrganization <org> }



.NOTES
Search Tags: a-registered-powershell-challenge, edit WinVer

.LINK
https://ironscripter.us/a-registered-powershell-challenge/


#>





function GetWinVerRegistrationSettings {
    
    param (
        [switch]$whatif, #Yeah I know, should use "ShouldProcess"
        [Parameter(ValueFromPipeline)][string]$ComputerName
        
    )

    $RegPathWin64 = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\"
    $RegPathWoW = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\"


        if($whatif){
            Write-Host "Whatif: Return current system RegisteredOwner and RegisteredOrganization"
        }elseif($ComputerName){

            Invoke-Command -ComputerName $($ComputerName) -ScriptBlock {
                $RegPathWin64 = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\"
                $RegPathWoW = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\"

                $WinVerSettingsTable = New-Object PSObject
                #Get
                    #WIN64        
                $WinVerSettingsTable | Add-Member NoteProperty -Name "RegisteredOwner" -Value "$((Get-itemproperty $RegPathWin64).RegisteredOwner)" -ErrorAction silentlycontinue
                $WinVerSettingsTable | Add-Member NoteProperty -Name "RegisteredOrganization" -Value "$((Get-itemproperty $RegPathWin64).RegisteredOrganization)" -ErrorAction silentlycontinue
                    #WIN6432
                $WinVerSettingsTable | Add-Member NoteProperty -Name "RegisteredOwnerWOW6432" -Value "$((Get-itemproperty $RegPathWoW).RegisteredOwner)" -ErrorAction silentlycontinue
                $WinVerSettingsTable | Add-Member NoteProperty -Name "RegisteredOrganizationWOW6432" -Value "$((Get-itemproperty $RegPathWoW).RegisteredOrganization)" -ErrorAction silentlycontinue
                #Output
                $WinVerSettingsTable
            }
        }else{
            #Does key-value exist
            $ValueWin64_RO = (Get-ItemProperty $RegPathWin64).PSObject.Properties.Name -contains "RegisteredOwner"
            $ValueWin64_RORG = (Get-ItemProperty $RegPathWin64).PSObject.Properties.Name -contains "RegisteredOrganization"
            $ValueWin32_RO = (Get-ItemProperty $RegPathWoW).PSObject.Properties.Name -contains "RegisteredOwner"
            $ValueWin32_ROORG = (Get-ItemProperty $RegPathWoW).PSObject.Properties.Name -contains "RegisteredOrganization"
        
            $WinVerSettingsTable = New-Object PSObject
            #Get
                #WIN64        
            $WinVerSettingsTable | Add-Member NoteProperty -Name "RegisteredOwner" -Value "$((Get-itemproperty $RegPathWin64).RegisteredOwner)" -ErrorAction silentlycontinue
            $WinVerSettingsTable | Add-Member NoteProperty -Name "RegisteredOrganization" -Value "$((Get-itemproperty $RegPathWin64).RegisteredOrganization)" -ErrorAction silentlycontinue
                #WIN6432
            $WinVerSettingsTable | Add-Member NoteProperty -Name "RegisteredOwnerWOW6432" -Value "$((Get-itemproperty $RegPathWoW).RegisteredOwner)" -ErrorAction silentlycontinue
            $WinVerSettingsTable | Add-Member NoteProperty -Name "RegisteredOrganizationWOW6432" -Value "$((Get-itemproperty $RegPathWoW).RegisteredOrganization)" -ErrorAction silentlycontinue
            #Output
            $WinVerSettingsTable
        }
}



function SetWinVerRegistrationSettings {

    param (
        [switch]$whatif, #Yeah I know, should use "ShouldProcess"
        [Parameter(Mandatory=$True)][string]$RegisteredOrganization,
        [Parameter(Mandatory=$False)][string]$RegisteredOwner,
        [Parameter(ValueFromPipeline)][string]$ComputerName
        
    )


    $RegPathWin64 = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\"
    $RegPathWoW = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\"


        if($whatif){
            if($RegisteredOwner -and $RegisteredOrganization){
                Write-Host "Whatif: Set current system RegisteredOwner $($RegisteredOwner) and RegisteredOrganization $($RegisteredOrganization)"
            }elseif($RegisteredOwner){
                Write-Host "Whatif: Set current system RegisteredOwner $($RegisteredOwner)"
            }elseif($RegisteredOrganization){
                Write-Host "Whatif: Set current system RegisteredOrganization $($RegisteredOrganization)"
            }
            
        }elseif($ComputerName){
            
            Invoke-Command -ComputerName $($ComputerName) -ScriptBlock {
                Write-Host "Setting remote computer $($Using:ComputerName) RegisteredOwner $($Using:RegisteredOwner) and RegisteredOrganization $($Using:RegisteredOrganization)"
                
                $RegPathWin64 = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\"
                $RegPathWoW = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\"

                #Does key-value exist
                $ValueWin64_RO = (Get-ItemProperty $RegPathWin64).PSObject.Properties.Name -contains "RegisteredOwner"
                $ValueWin64_RORG = (Get-ItemProperty $RegPathWin64).PSObject.Properties.Name -contains "RegisteredOrganization"
                $ValueWin32_RO = (Get-ItemProperty $RegPathWoW).PSObject.Properties.Name -contains "RegisteredOwner"
                $ValueWin32_ROORG = (Get-ItemProperty $RegPathWoW).PSObject.Properties.Name -contains "RegisteredOrganization"
            
                if($Using:RegisteredOrganization){
                    Write-Host "....--- RegisteredOrganization"
                    if($ValueWin64_RORG){
                        Write-Host "Updating $RegPathWin64 RegisteredOrganization"
                        Set-Itemproperty -Path $RegPathWin64 -Name RegisteredOrganization -Value "$($Using:RegisteredOrganization)"
                        
                    }else{
                        Write-Host "Creating missing registry value: $RegPathWin64 RegisteredOrganization"
                        New-Itemproperty -Path $RegPathWin64 -Name RegisteredOrganization -Value "$($Using:RegisteredOrganization)"
                    }
                    if($ValueWin32_ROORG){
                        Write-Host "Updating $RegPathWoW RegisteredOrganization"
                        Set-Itemproperty -Path $RegPathWoW -Name RegisteredOrganization -Value "$($Using:RegisteredOrganization)"  
                    }else{
                        Write-Host "Creating missing registry value: $RegPathWoW RegisteredOrganization"
                        New-Itemproperty -Path $RegPathWoW -Name RegisteredOrganization -Value "$($Using:RegisteredOrganization)"
                    }

                }
                if($Using:RegisteredOwner){

                    if($ValueWin64_RORG){
                        Write-Host "Updating $RegPathWoW RegisteredOwner"
                        Set-Itemproperty -Path $RegPathWin64 -Name RegisteredOwner -Value "$($Using:RegisteredOwner)"  
                    }else{
                        Write-Host "Creating missing registry value: $RegPathWin64 RegisteredOwner"
                        New-Itemproperty -Path $RegPathWin64 -Name RegisteredOwner -Value "$($Using:RegisteredOwner)"
                    }
                    if($ValueWin32_ROORG){
                        Write-Host "Updating $RegPathWoW RegisteredOwner"
                        Set-Itemproperty -Path $RegPathWoW -Name RegisteredOwner -Value "$($Using:RegisteredOwner)"  
                    }else{
                        Write-Host "Creating missing registry value: $RegPathWoW RegisteredOwner"
                        New-Itemproperty -Path $RegPathWoW -Name RegisteredOwner -Value "$($Using:RegisteredOwner)"
                    }

                }   
            }
        }else{
            #Does key-value exist
            $ValueWin64_RO = (Get-ItemProperty $RegPathWin64).PSObject.Properties.Name -contains "RegisteredOwner"
            $ValueWin64_RORG = (Get-ItemProperty $RegPathWin64).PSObject.Properties.Name -contains "RegisteredOrganization"
            $ValueWin32_RO = (Get-ItemProperty $RegPathWoW).PSObject.Properties.Name -contains "RegisteredOwner"
            $ValueWin32_ROORG = (Get-ItemProperty $RegPathWoW).PSObject.Properties.Name -contains "RegisteredOrganization"
        
            if($RegisteredOrganization){
                
                if($ValueWin64_RORG){
                    Set-Itemproperty -Path $RegPathWin64 -Name RegisteredOrganization -Value "$($RegisteredOrganization)"  
                    
                }else{
                    New-Itemproperty -Path $RegPathWin64 -Name RegisteredOrganization -Value "$($RegisteredOrganization)"
                }
                if($ValueWin32_ROORG){
                    Set-Itemproperty -Path $RegPathWoW -Name RegisteredOrganization -Value "$($RegisteredOrganization)"  
                }else{
                    New-Itemproperty -Path $RegPathWoW -Name RegisteredOrganization -Value "$($RegisteredOrganization)"
                }

            }
            if($RegisteredOwner){

                if($ValueWin64_RORG){
                    Set-Itemproperty -Path $RegPathWin64 -Name RegisteredOwner -Value "$($RegisteredOwner)"  
                }else{
                    New-Itemproperty -Path $RegPathWin64 -Name RegisteredOwner -Value "$($RegisteredOwner)"
                }
                if($ValueWin32_ROORG){
                    Set-Itemproperty -Path $RegPathWoW -Name RegisteredOwner -Value "$($RegisteredOwner)"  
                }else{
                    New-Itemproperty -Path $RegPathWoW -Name RegisteredOwner -Value "$($RegisteredOwner)"
                }

            }            
        }
}



