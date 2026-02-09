# Script to add Flutter to PATH
$flutterPath = "C:\flutter\bin"

# Get current PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Check if Flutter is already in PATH
if ($currentPath -notlike "*$flutterPath*") {
    # Add Flutter to PATH
    $newPath = "$currentPath;$flutterPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "✅ Flutter đã được thêm vào PATH!" -ForegroundColor Green
    Write-Host "📌 Vui lòng đóng và mở lại terminal để áp dụng thay đổi." -ForegroundColor Yellow
} else {
    Write-Host "✅ Flutter đã có trong PATH rồi!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Đường dẫn Flutter: $flutterPath" -ForegroundColor Cyan
