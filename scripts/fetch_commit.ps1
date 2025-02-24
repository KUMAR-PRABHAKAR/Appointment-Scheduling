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
$shelveSetURL = "$orgURL/repos/$repoOwner/$repoName/commits?sha=$branchName&timestamp=$(Get-Date -UFormat %s)"
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
Write-Host "🔍 Latest Commit SHA: $($latestCommit.sha)"
Write-Host "🔍 Latest Commit Message: $($latestCommit.commit.message)"
Write-Host "🔍 Latest Commit Author: $($latestCommit.commit.author.name)"


# Validate commit details
if ([string]::IsNullOrEmpty($commitSha)) {
    Write-Host "❌ ERROR: No commit SHA found."
    exit 1
}

# Fetch commit details, including changed files
$commitURL = "$orgURL/repos/$repoOwner/$repoName/commits/$commitSha"
Write-Host "🔍 Fetching commit details from: $commitURL"

try {
    $commitInfo = Invoke-RestMethod -Uri $commitURL -Method Get -ContentType "application/json" -Headers $header
} catch {
    Write-Host "❌ ERROR: Failed to fetch commit details. $_"
    exit 1
}

Write-Host "🔍 API Response from GitHub:"
$shelveSetinfo | ConvertTo-Json -Depth 3  # Print full API response for debugging


# Extract changed files
$changedFiles = if ($commitInfo.PSObject.Properties["files"] -ne $null) {
    $commitInfo.files | ForEach-Object { $_.filename }
} else {
    Write-Host "⚠️ No changed files found in commit."
    @()
}

# Store Details in an Array
$commitDetails = @{
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

# Remove old file before writing new commit details
if (Test-Path $jsonFilePath) {
    Remove-Item -Path $jsonFilePath -Force
    Write-Host "🔄 Old commit-details.json deleted."
}

# Save JSON file
$commitDetails | ConvertTo-Json -Depth 3 | Set-Content -Encoding utf8 $jsonFilePath
Write-Host "✅ commit-details.json successfully updated at: $jsonFilePath"

# Debugging output: Print file contents
Write-Host "🔍 New commit-details.json content:"
Get-Content $jsonFilePath
