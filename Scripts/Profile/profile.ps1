###

# Remove path in prompt
function prompt {
	$p = Split-Path -leaf -path (Get-Location)
	"$($env:username)@$($p)> "
}