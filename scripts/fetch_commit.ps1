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

# Fetch latest commits from GitHub
$shelveSetURL = "$orgURL/repos/$repoOwner/$repoName/commits?sha=$branchName"
Write-Host "🔍 Fetching commits from: $shelveSetURL"

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

# Define the JSON output file path using GitHub Actions workspace
$artifactFolder = "$env:GITHUB_WORKSPACE/artifacts"
$jsonFilePath = "$artifactFolder/commit-details.json"

# Ensure artifacts folder exists
if (-Not (Test-Path $artifactFolder)) {
    New-Item -ItemType Directory -Path $artifactFolder | Out-Null
}

# Save JSON file
$commitDetails | ConvertTo-Json -Depth 3 | Out-File -Encoding utf8 $jsonFilePath

# Verify that the file was created
if (-Not (Test-Path $jsonFilePath)) {
    Write-Host "❌ ERROR: commit-details.json was NOT created!"
    exit 1
} else {
    Write-Host "✅ commit-details.json successfully created at: $jsonFilePath"
}
