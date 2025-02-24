# Set GitHub API URL and repository details
$orgURL = "https://api.github.com"
$repoOwner = "KUMAR-PRABHAKAR"  # ✅ Your GitHub username
$repoName = "Appointment-Scheduling"  # ✅ Your repository name
$branchName = "main"  # ✅ Your working branch

# Get the GitHub Token from environment variables
$myToken = $env:MY_GITHUB_TOKEN

# Validate if the GitHub token exists
if ([string]::IsNullOrEmpty($myToken)) {
    Write-Host "❌ ERROR: GitHub Token is missing!"
    exit 1
} else {
    Write-Host "✅ GitHub Token is set."
}

# Set Headers for API Request
$header = @{
    Authorization = "token $($myToken)"
    Accept        = "application/vnd.github.v3+json"
}

# Force GitHub API to fetch the latest commit by adding a timestamp
$shelveSetURL = "$orgURL/repos/$repoOwner/$repoName/commits?sha=$branchName&nocache=$(Get-Date -UFormat %s)"
Write-Host "🔍 Fetching latest commits from: $shelveSetURL"

try {
    $shelveSetinfo = Invoke-RestMethod -Uri $shelveSetURL -Method Get -ContentType "application/json" -Headers $header
} catch {
    Write-Host "❌ ERROR: Failed to fetch commits from GitHub API. $_"
    exit 1
}

# Extract latest commit details
if ($shelveSetinfo.Count -eq 0) {
    Write-Host "❌ ERROR: No commit data received."
    exit 1
}

$latestCommit = $shelveSetinfo[0]
$commitSha = $latestCommit.sha
$commitMessage = $latestCommit.commit.message
$commitAuthor = $latestCommit.commit.author.name
$commitDate = $latestCommit.commit.author.date

# Debugging output
Write-Host "🔍 Latest Commit SHA: $commitSha"
Write-Host "🔍 Latest Commit Message: $commitMessage"

# Fetch commit details, including changed files
$commitURL = "$orgURL/repos/$repoOwner/$repoName/commits/$commitSha"
Write-Host "🔍 Fetching commit details from: $commitURL"

try {
    $commitInfo = Invoke-RestMethod -Uri $commitURL -Method Get -ContentType "application/json" -Headers $header
} catch {
    Write-Host "❌ ERROR: Failed to fetch commit details. $_"
    exit 1
}

# Extract changed files
$changedFiles = if ($commitInfo.PSObject.Properties["files"] -ne $null) {
    $commitInfo.files | ForEach-Object { $_.filename }
} else {
    Write-Host "⚠️ No changed files found in commit."
    @()
}

# Store the new commit details
$newCommit = @{
    CommitSHA     = $commitSha
    CommitMessage = $commitMessage
    CommitAuthor  = $commitAuthor
    CommitDate    = $commitDate
    ChangedFiles  = $changedFiles
}

# Determine correct workspace path for local vs GitHub Actions
if ($env:GITHUB_WORKSPACE) {
    # Running inside GitHub Actions
    $artifactFolder = "$env:GITHUB_WORKSPACE/artifacts"
} else {
    # Running locally
    $artifactFolder = "C:\Users\kumar\Desktop\Appointment-Scheduling-master\artifacts"
}

$jsonFilePath = "$artifactFolder/commit-details.json"

# Ensure artifacts folder exists
if (-Not (Test-Path $artifactFolder)) {
    New-Item -ItemType Directory -Path $artifactFolder | Out-Null
}

# Read existing commit details if the file already exists
if (Test-Path $jsonFilePath) {
    Write-Host "🔄 commit-details.json exists. Reading existing data..."
    $existingData = Get-Content -Raw -Path $jsonFilePath | ConvertFrom-Json
} else {
    Write-Host "🆕 commit-details.json does not exist. Creating a new one."
    $existingData = @()
}

# Ensure $existingData is an array
if ($existingData -isnot [System.Collections.IEnumerable]) {
    $existingData = @($existingData)
}

# Append the new commit details
$updatedData = $existingData + $newCommit

# Save updated commit details to the JSON file
$updatedData | ConvertTo-Json -Depth 3 | Set-Content -Encoding utf8 $jsonFilePath
Write-Host "✅ commit-details.json successfully updated with new commit at: $jsonFilePath"

# Debugging output: Print file contents
Write-Host "🔍 Updated commit-details.json content:"
Get-Content $jsonFilePath
