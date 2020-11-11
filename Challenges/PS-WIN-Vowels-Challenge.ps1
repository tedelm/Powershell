<#

Find vowels in word
Vowels = a,e,i,o,u


#>



function Find-Vowels {
    param (
        [string]$word
    )
    $vowels = @("a","e","i","o","u")

    $chararray = $($word.ToLower()).ToCharArray()
    $i = 0
    $vowelsFound = @()

    foreach ($char in $chararray) {

        if($char -in $vowels){
            $vowelsFound += $char
            $i++
        }
    }

    Write-host "$i Vowel(s), these-> $vowelsFound"
}

