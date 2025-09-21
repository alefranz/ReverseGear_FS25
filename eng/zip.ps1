$source = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$zipPath = Join-Path $source "FS25_ReverseGear.zip"

# Define exclusions
$excludePatterns = @(
  "eng\*",
  ".git*",
  "LICENCE",
  "README.md",
  ".gitattributes",
  "*.png"
)

# Get all files except excluded
$filesToZip = Get-ChildItem -Path $source -Recurse -File | Where-Object {
  $relativePath = $_.FullName.Substring($source.Length + 1)
  foreach ($pattern in $excludePatterns) {
    if ($relativePath -like $pattern) { return $false }
  }
  return $true
}

# Remove existing zip if present
if (Test-Path $zipPath) { Remove-Item $zipPath }

# Create the zip
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::Open($zipPath, 'Create')
foreach ($file in $filesToZip) {
  $entryName = $file.FullName.Substring($source.Length + 1)
  [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file.FullName, $entryName)
}
$zip.Dispose()
Write-Host "Created $zipPath"
