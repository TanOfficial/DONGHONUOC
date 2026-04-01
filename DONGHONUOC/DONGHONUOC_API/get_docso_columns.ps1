$connectionString = "Server=MSI\SQLEXPRESS;Database=DocSoTH;Integrated Security=True;"
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
try {
    $connection.Open()
    $command = $connection.CreateCommand()
    $command.CommandText = "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DocSo'"
    $reader = $command.ExecuteReader()
    $columns = @()
    while ($reader.Read()) {
        $columns += $reader.GetString(0)
    }
    $reader.Close()
    
    $colsJoined = $columns -join ","
    Set-Content -Path "docso_columns_list.txt" -Value $colsJoined
    Write-Host "Got columns!"
} catch {
    Write-Host $_.Exception.Message
} finally {
    if ($connection.State -eq 'Open') { $connection.Close() }
}
