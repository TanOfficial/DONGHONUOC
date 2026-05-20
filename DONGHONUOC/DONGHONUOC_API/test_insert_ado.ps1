$connectionString = "Server=MSI\SQLEXPRESS;Database=DocSoTH;Integrated Security=True;"
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
try {
    $connection.Open()
    $command = $connection.CreateCommand()
    $command.CommandText = "INSERT INTO NguoiDungB (Username, PasswordHash, HoTen) VALUES ('test', 'pass', 'name')"
    $command.ExecuteNonQuery()
    Write-Host "SUCCESS"
} catch {
    $err = $_.Exception.Message
    if ($_.Exception.InnerException) {
        $err += " | " + $_.Exception.InnerException.Message
    }
    Set-Content -Path "sql_error.txt" -Value $err
} finally {
    if ($connection.State -eq 'Open') { $connection.Close() }
}
