# Set script execution policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

Write-Host "=== Step 1: Checkout Repository ==="
# Ensure the script is running in the correct directory
$repoPath = "C:\Users\kumar\Desktop\Appointment-Scheduling-master"  # ✅ Updated to match your project path

if (-Not (Test-Path $repoPath)) {
    Write-Host "❌ ERROR: Repository path not found: $repoPath"
    exit 1
}
Set-Location $repoPath

Write-Host "=== Step 2: Verify PowerShell Installation ==="
try {
    $pwshVersion = pwsh --version
    Write-Host "✅ PowerShell Version: $pwshVersion"
} catch {
    Write-Host "❌ ERROR: PowerShell is not installed or not found!"
    exit 1
}

Write-Host "=== Step 3: Set GitHub Token as Environment Variable ==="
# Ensure the GitHub token is available
if (-Not $env:MY_GITHUB_TOKEN) {
    Write-Host "❌ ERROR: MY_GITHUB_TOKEN is not set! Add it as an environment variable."
    exit 1
} else {
    Write-Host "✅ MY_GITHUB_TOKEN is set."
}

Write-Host "=== Step 4: Run fetch_commit.ps1 ==="
# Run the fetch_commit.ps1 script
$scriptPath = "C:\Users\kumar\Desktop\Appointment-Scheduling-master\scripts\fetch_commit.ps1"  # ✅ Updated script path

if (-Not (Test-Path $scriptPath)) {
    Write-Host "❌ ERROR: Script file not found: $scriptPath"
    exit 1
}

# Execute the fetch_commit.ps1 script
try {
    pwsh -ExecutionPolicy Bypass -File $scriptPath
} catch {
    Write-Host "❌ ERROR: Failed to execute fetch_commit.ps1! $_"
    exit 1
}

# Check if commit-details.json was generated
$jsonFilePath = "C:\Users\kumar\Desktop\Appointment-Scheduling-master\commit-details.json"  # ✅ Updated JSON path

if (-Not (Test-Path $jsonFilePath)) {
    Write-Host "❌ ERROR: commit-details.json was not generated!"
    exit 1
}

Write-Host "=== Step 5: Print Commit Details ==="
Get-Content $jsonFilePath

Write-Host "=== Step 6: Simulate Uploading Artifact ==="
# Define artifacts folder path
$artifactFolder = "C:\Users\kumar\Desktop\Appointment-Scheduling-master\artifacts"  # ✅ Updated artifacts path

# Create artifacts folder if it doesn't exist
if (-Not (Test-Path $artifactFolder)) {
    New-Item -ItemType Directory -Path $artifactFolder | Out-Null
}

# Copy the JSON file to artifacts folder
$destinationFile = "$artifactFolder\commit-details.json"
try {
    Copy-Item -Path $jsonFilePath -Destination $destinationFile -Force
    Write-Host "✅ Commit details successfully copied to: $destinationFile"
} catch {
    Write-Host "❌ ERROR: Failed to copy commit-details.json to artifacts folder. $_"
    exit 1
}

Write-Host "✅ Workflow execution completed successfully!"
