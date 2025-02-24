# Set GitHub API URL and repository details
$orgURL = "https://api.github.com"
$repoOwner = "KUMAR-PRABHAKAR"  # ✅ Update with your GitHub username
$repoName = "Appointment-Scheduling"  # ✅ Update with your repo name
$branchName = "main"  # ✅ Change if you're using a different branch

# Get the GitHub Token from environment variables
$myToken = $env:MY_GITHUB_TOKEN  # ✅ This should be set in GitHub Actions or your local environment

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

# Debug: Print API response
Write-Host "🔍 Response from Commit API:"
$shelveSetinfo | ConvertTo-Json -Depth 3

# Validate response before extracting commit data
if ($shelveSetinfo.Count -eq 0) {
    Write-Host "❌ ERROR: No commit data received."
    exit 1
}

# Extract latest commit details
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

# Debug: Print the commit response
Write-Host "🔍 Response from Commit Details API:"
$commitInfo | ConvertTo-Json -Depth 3

# Extract changed files
if ($commitInfo.PSObject.Properties["files"] -ne $null) {
    $changedFiles = $commitInfo.files | ForEach-Object { $_.filename }
} else {
    Write-Host "⚠️ No changed files found in commit."
    $changedFiles = @()
}

# Store Details in an Array
$commitDetails = @{
    CommitSHA     = $commitSha
    CommitMessage = $commitMessage
    CommitAuthor  = $commitAuthor
    CommitDate    = $commitDate
    ChangedFiles  = $changedFiles
}

# Define the JSON output file path inside artifacts folder
$artifactFolder = "C:\Users\kumar\Desktop\Appointment-Scheduling-master\artifacts"
$jsonFilePath = "$artifactFolder\commit-details.json"

# Ensure the artifacts folder exists
if (-Not (Test-Path $artifactFolder)) {
    New-Item -ItemType Directory -Path $artifactFolder | Out-Null
}

# Convert to JSON and Save to a File
$jsonOutput = $commitDetails | ConvertTo-Json -Depth 3
Write-Host "✅ Generated JSON Data:"
Write-Host $jsonOutput

$jsonOutput | Out-File -Encoding utf8 $jsonFilePath
Write-Host "✅ Commit details saved to: $jsonFilePath"
