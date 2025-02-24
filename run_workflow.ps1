# Set script execution policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

Write-Host "=== Step 1: Checkout Repository ==="
# Simulate checkout by ensuring script is run in correct repo
$repoPath = "C:\Users\kumar\Desktop\Appointment-Scheduling-master" # Update if needed
if (-Not (Test-Path $repoPath)) {
    Write-Host "❌ ERROR: Repository path not found: $repoPath"
    exit 1
}
Set-Location $repoPath

Write-Host "=== Step 2: Verify PowerShell Installation ==="
$pwshVersion = pwsh --version
Write-Host "✅ PowerShell Version: $pwshVersion"

Write-Host "=== Step 3: Set GitHub Token as Environment Variable ==="
# Ensure the token is set before running the script
if (-Not $env:MY_GITHUB_TOKEN) {
    Write-Host "❌ ERROR: MY_GITHUB_TOKEN is not set!"
    exit 1
} else {
    Write-Host "✅ MY_GITHUB_TOKEN is set."
}

Write-Host "=== Step 4: Run fetch_commit.ps1 ==="
# Run the PowerShell script that fetches commit details
$scriptPath = ".\scripts\fetch_commit.ps1"
if (-Not (Test-Path $scriptPath)) {
    Write-Host "❌ ERROR: Script file not found: $scriptPath"
    exit 1
}

pwsh -ExecutionPolicy Bypass -File $scriptPath

# Determine correct path for local vs GitHub Actions
if ($env:GITHUB_WORKSPACE) {
    $jsonFilePath = "$env:GITHUB_WORKSPACE/artifacts/commit-details.json"
} else {
    $jsonFilePath = "C:\Users\kumar\Desktop\Appointment-Scheduling-master\artifacts\commit-details.json"
}

# Debugging: Print actual file path
Write-Host "🔍 Checking for commit-details.json at: $jsonFilePath"

# Debugging: List all files in the artifacts directory
if (Test-Path "C:\Users\kumar\Desktop\Appointment-Scheduling-master\artifacts") {
    Write-Host "🔍 Listing all files in artifacts folder:"
    Get-ChildItem -Path "C:\Users\kumar\Desktop\Appointment-Scheduling-master\artifacts" -Recurse
} else {
    Write-Host "⚠️ WARNING: Artifacts folder does not exist."
}

# Check if commit-details.json exists
if (-Not (Test-Path $jsonFilePath)) {
    Write-Host "❌ ERROR: commit-details.json was not generated!"
    exit 1
} else {
    Write-Host "✅ commit-details.json successfully found at: $jsonFilePath"
}

Write-Host "=== Step 5: Print Commit Details ==="
Get-Content $jsonFilePath

Write-Host "=== Step 6: Simulate Uploading Artifact ==="

# Define artifact folder
$artifactFolder = "C:\Users\kumar\Desktop\Appointment-Scheduling-master\artifacts"

# Debugging: Print paths before copying
Write-Host "🔍 Source Path: $jsonFilePath"
Write-Host "🔍 Destination Path: $artifactFolder\commit-details.json"

# Only copy if source and destination are different
if ($jsonFilePath -ne "$artifactFolder\commit-details.json") {
    Copy-Item -Path $jsonFilePath -Destination "$artifactFolder\commit-details.json" -Force
    Write-Host "✅ commit-details.json copied successfully!"
} else {
    Write-Host "⚠️ Skipping copy: Source and destination are the same."
}

Write-Host "✅ Workflow execution completed successfully!"
