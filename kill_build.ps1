$procs = Get-Process | Where-Object { $_.Name -in @('cmake','ninja','vcpkg','cl','link') }
if ($procs) {
    $procs | ForEach-Object { Write-Host "Killing: $($_.Name) ($($_.Id))"; $_ | Stop-Process -Force }
    Write-Host "Killed $($procs.Count) processes"
} else {
    Write-Host "No build processes running"
}

# Delete vcpkg lock files
$lockFiles = Get-ChildItem -Path "D:\FOGNITX\build" -Recurse -Filter "vcpkg-running.lock" -ErrorAction SilentlyContinue
foreach ($f in $lockFiles) {
    Remove-Item $f.FullName -Force
    Write-Host "Deleted lock: $($f.FullName)"
}
Write-Host "Done"
