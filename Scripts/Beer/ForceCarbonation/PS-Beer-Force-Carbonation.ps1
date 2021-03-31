<#
.SYNOPSIS
Calculate Beer Co2 levels with force carbonation

.DESCRIPTION
Setup:
1. Load script/functions by running ". .\PS-Beer-Force-Carbonation.ps1"
2. Run one of the examples:

#Using custom carbonation level
ForceCarbonation -Temp_c 20 -Co2 2.6
#Using custom carbonation level with Fahrenheit
ForceCarbonation -Temp_f 68 -Co2 2.6
#Using input syle
ForceCarbonation -Temp_c 20 -Style AAA
#Using pre defined style
ForceCarbonation -Temp_c 20 -IPA
#Using pre defined level
ForceCarbonation -FastMid 16



.NOTES
Author
Ted Elmenheim
Created: 2021-03-31
Edited: 


Search Tags: Beer, Carbonation, co2


.EXAMPLE
Load script/functions by running ". .\PS-Beer-Force-Carbonation.ps1"
Run one of the examples:

#Using custom carbonation level
ForceCarbonation -Temp_c 20 -Co2 2.6
#Using custom carbonation level with Fahrenheit
ForceCarbonation -Temp_f 68 -Co2 2.6
#Using input syle
ForceCarbonation -Temp_c 20 -Style AAA
#Using pre defined style
ForceCarbonation -Temp_c 20 -IPA
#Using pre defined levels 16,14,12
ForceCarbonation -FastMid 16
#Using pre defined levels 48,34,30
ForceCarbonation -FastHigh 48 

.LINK

#>


function ForceCarbonation {
    param (
        [decimal]$Temp_c,
        [decimal]$Temp_f,
        [decimal]$Co2,
        [String]$Style,
        [int]$FastMid,
        [int]$FastHigh,
        [Switch]$IPA,
        [Switch]$AAA,
        [Switch]$Lager,
        [Switch]$Pilsner
    )

if(!$Temp_f){
    $Temp_f = $Temp_c * 1.8+32
}else{
    $Temp_c = $Temp_f/(1.8+32)
}

if($Style){
    switch ($Style)
    {
        AAA         { $Co2 = 2.3    }
        IPA         { $Co2 = 2.5    }
        Lager       { $Co2 = 2.6    }
        Pilsner     { $Co2 = 2.6    }
        default     { $Co2 }
    }
}

if(!$Style -and !$Co2){
    if($IPA)            { $Co2 = 2.5 }
    if($AAA)            { $Co2 = 2.3 }
    if($Lager)          { $Co2 = 2.6 }
    if($Pilsner)        { $Co2 = 2.6 }
}

    if($FastMid){
        #Hours
        switch ($FastMid)
        {
            16{ $BAR = 2    }
            14{ $BAR = 2.4  }
            12{ $BAR = 2.75 }
            default     { $OOB = "Available options (h): 16,14,12"; $BAR = 0 }
        }

        $PSI = $BAR * 14.503773773
        Write-host "Celsius: $Temp_c"
        Write-host "Fahrenheit: $Temp_f"
        Write-host "Wanted Co2 level: Low/Mid"
        Write-host "PSI: $([math]::Round($PSI,2))"
        Write-host "BAR: $([math]::Round($BAR,2))"
        Write-host "Duration: $FastMid hours"        

    }elseif($FastHigh){
        #Hours
        switch ($FastHigh)
        {
            48{ $BAR = 2    }
            34{ $BAR = 2.4  }
            30{ $BAR = 2.75 }
            default     { $OOB = "Available options (h): 48,34,30"; $BAR = 0 }
        }

        $PSI = $BAR * 14.503773773
        Write-host "Celsius: $Temp_c"
        Write-host "Fahrenheit: $Temp_f"
        Write-host "Wanted Co2 level: High"
        Write-host "PSI: $([math]::Round($PSI,2))"
        Write-host "BAR: $([math]::Round($BAR,2))"
        Write-host "Duration: $FastHigh hours"
    }else {

        $PSI = (-16.6999 - (0.0101059*$Temp_f)) + (0.00116512*($Temp_f*$Temp_f)) + ((0.173354*$Temp_f)*$Co2) + ((4.24267*$Co2) - (0.0684226*($Co2*$Co2)))
        $BAR = $PSI * 0.0689475729  

        Write-host "Celsius: $Temp_c"
        Write-host "Fahrenheit: $Temp_f"
        Write-host "Wanted Co2 level: $Co2"
        Write-host "PSI: $([math]::Round($PSI,2))"
        Write-host "BAR: $([math]::Round($BAR,2))"
        Write-host "Duration: 7-10 Days"

    }

    write-host $OOB -ForegroundColor red -BackgroundColor Yellow
    $OOB = $null


}
