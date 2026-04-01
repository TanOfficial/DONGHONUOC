try {
    Invoke-Sqlcmd -ServerInstance "MSI\SQLEXPRESS" -Database "DocSoTH" -Query "INSERT INTO NguoiDungB (Username, PasswordHash, HoTen) VALUES ('test', 'pass', 'name')" -ErrorAction Stop
} catch {
    Write-Host $_.Exception.Message
}
