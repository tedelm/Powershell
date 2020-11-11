<#

Find vowels in word
Vowels = a,e,i,o,u
Consonants = "b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "z", "x"

#>



function Find-Vowels {
    param (
        [string]$word,
        [array]$vowels = @("a","e","i","o","u", "y", "å", "ä", "ö"),
        [array]$consonants = @("b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "z", "x")
    )

    
    
    $chararray = $($word.ToLower()).ToCharArray()
    $i = 0
    $ii = 0
    $vowelsFound = @()

    foreach ($char in $chararray) {

        if($char -in $vowels){
            $vowelsFound += $char
            $i++
        }
    }
    foreach ($char in $chararray) {

        if($char -in $consonants){
            $consonantsFound += $char
            $ii++
        }
    }    

    Write-host "$i Vowel(s), these-> $vowelsFound"
    Write-host "$ii Consonant(s), these-> $consonantsFound"
}

