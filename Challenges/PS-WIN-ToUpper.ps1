<#
Make every first letter in word CAP-size

#>


$lorem = "Lorem ipsum dolor sit amet consectetur adipisicing elit. Accusantium suscipit beatae nemo quidem quas, ducimus dolorem deserunt in eius, minus iure dolorum quasi quis expedita? Amet nam deserunt distinctio eligendi?"

foreach ($word in $lorem.split(" ")) {
    
    $loremOut += "$($word.substring(0,1).ToUpper()+$word.substring(1)) "
    
}
$loremOut