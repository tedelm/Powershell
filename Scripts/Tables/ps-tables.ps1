<# 

#>



$table = New-Object System.Data.Datatable

# Adding columns
[void]$table.Columns.Add("Name")
[void]$table.Columns.Add("Age")
[void]$table.Columns.Add("Location")

# Adding rows
[void]$table.Rows.Add("brian","23","UK")
[void]$table.Rows.Add("sam","32","Canada")
[void]$table.Rows.Add("eric","25","USA")

$table


