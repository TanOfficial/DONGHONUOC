$connectionString = "Server=.\SQLEXPRESS;Database=DocSoTH;Integrated Security=True;"
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
try {
    $connection.Open()
    Write-Host "SUCCESS_LOCAL"
    $connection.Close()
} catch {
    Write-Host "ERROR_LOCAL: " $_.Exception.Message
}
$connectionString2 = "Server=localhost\SQLEXPRESS;Database=DocSoTH;Integrated Security=True;"
$connection2 = New-Object System.Data.SqlClient.SqlConnection($connectionString2)
try {
    $connection2.Open()
    Write-Host "SUCCESS_LOCALHOST"
    $connection2.Close()
} catch {
    Write-Host "ERROR_LOCALHOST: " $_.Exception.Message
}
