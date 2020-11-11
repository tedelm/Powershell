<#
The FizzBuzz challenge
loop thru 1-100, 
  - every time it can be devided by 3 and 5, call out FizzBuzz
  - every time it can be devided by 3, call out Fizz
  - every time.... devided by 5, call out Buzz

#>

$i = 0
while($i -ne 100){

    if($(($i / 3) -match "^\d+$") -and $(($i / 5) -match "^\d+$")){
        write-host "$i FizzBuzz"
    }elseif(($i / 3) -match "^\d+$"){
        write-host "$i Fizz"
    }
    elseif(($i / 5) -match "^\d+$"){
        write-host "$i Buzz"
    }else{
        #No bueno
    }    

    $i++
    
}

