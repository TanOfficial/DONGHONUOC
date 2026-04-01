$connectionString = "Server=MSI\SQLEXPRESS;Database=DocSoTH;Integrated Security=True;"
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
try {
    $connection.Open()
    $command = $connection.CreateCommand()

    Write-Host "Adding new IDENTITY column..."
    $command.CommandText = "ALTER TABLE NguoiDungB ADD MaND_New INT IDENTITY(1000, 1) NOT NULL;"
    $command.ExecuteNonQuery()

    Write-Host "Dropping old Primary Key constraint..."
    # We need to find the PK name dynamically just in case it's not exactly PK_NguoiDungB
    $command.CommandText = "SELECT name FROM sys.key_constraints WHERE type = 'PK' AND parent_object_id = OBJECT_ID('NguoiDungB')"
    $pkName = $command.ExecuteScalar()
    if ($pkName) {
        $command.CommandText = "ALTER TABLE NguoiDungB DROP CONSTRAINT $pkName;"
        $command.ExecuteNonQuery()
    }

    Write-Host "Dropping old column..."
    $command.CommandText = "ALTER TABLE NguoiDungB DROP COLUMN MaND;"
    $command.ExecuteNonQuery()

    Write-Host "Renaming new column..."
    $command.CommandText = "EXEC sp_rename 'NguoiDungB.MaND_New', 'MaND', 'COLUMN';"
    $command.ExecuteNonQuery()

    Write-Host "Re-creating Primary Key..."
    $command.CommandText = "ALTER TABLE NguoiDungB ADD CONSTRAINT PK_NguoiDungB PRIMARY KEY (MaND);"
    $command.ExecuteNonQuery()

    Write-Host "SUCCESS"
} catch {
    Write-Host $_.Exception.ToString()
} finally {
    if ($connection.State -eq 'Open') { $connection.Close() }
}
