# Calculate Beer Co2 levels with force carbonation



### .SYNOPSIS

Calculate Beer Co2 levels with force carbonation  
  
### DESCRIPTION

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
  
### NOTES
Author  
Ted Elmenheim  
Created: 2021-03-31  
Edited:  
  
  
Search Tags: Beer, Carbonation, co2 
  
  
### EXAMPLE
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
  
  
# LINK
  

