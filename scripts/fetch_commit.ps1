# Set GitHub API URL
$orgURL = "https://api.github.com"
$repoOwner = "KUMAR-PRABHAKAR"  # Change this to your GitHub username
$repoName = "Appointment-Scheduling"
$branchName = "main"

# Get the GitHub Token from environment variables
$myToken = "$env:GITHUB_TOKEN"

# Set Headers for API Request
$header = @{
    Authorization = "token $($myToken)"
    Accept        = "application/vnd.github.v3+json"
}

# Get Latest Commit SHA from the Main Branch
$shelveSetURL = "$orgURL/repos/$repoOwner/$repoName/commits?sha=$branchName"
$shelveSetinfo = Invoke-RestMethod -Uri $shelveSetURL -Method Get -ContentType "application/json" -Headers $header

# Extract latest commit details
$latestCommit = $shelveSetinfo[0]
$commitSha = $latestCommit.sha
$commitMessage = $latestCommit.commit.message
$commitAuthor = $latestCommit.commit.author.name
$commitDate = $latestCommit.commit.author.date

# Get Changed Files in the Commit
$commitURL = "$orgURL/repos/$repoOwner/$repoName/commits/$commitSha"
$commitInfo = Invoke-RestMethod -Uri $commitURL -Method Get -ContentType "application/json" -Headers $header
$changedFiles = $commitInfo.files | ForEach-Object { $_.filename }

# Store Details in an Array
$commitDetails = @{
    CommitSHA    = $commitSha
    CommitMessage = $commitMessage
    CommitAuthor = $commitAuthor
    CommitDate   = $commitDate
    ChangedFiles = $changedFiles
}

# Convert to JSON and Save to a File
$commitDetails | ConvertTo-Json -Depth 0 | Out-File -Encoding utf8 "commit-details.json"

Write-Host "Commit details saved to commit-details.json"
