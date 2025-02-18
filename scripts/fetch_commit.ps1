# Set GitHub API URL and repository details
$orgURL = "https://api.github.com"  # GitHub API URL
$repoOwner = "KUMAR-PRABHAKAR"  # Change this to your GitHub username or organization
$repoName = "Appointment-Scheduling"  # Your repository name
$branchName = "main"  # Branch you are working on (default: main)

# Get the GitHub Token from environment variables (Make sure to set MY_GITHUB_TOKEN as a secret in GitHub Actions)
$myToken = "$env:MY_GITHUB_TOKEN"  # GitHub token for authentication

# Set Headers for API Request
$header = @{
    Authorization = "token $($myToken)"
    Accept        = "application/vnd.github.v3+json"
}

# Get Latest Commit SHA from the Main Branch
$shelveSetURL = "$orgURL/repos/$repoOwner/$repoName/commits?sha=$branchName"  # Get commits from the specified branch
$shelveSetinfo = Invoke-RestMethod -Uri $shelveSetURL -Method Get -ContentType "application/json" -Headers $header

# Extract latest commit details (Get the first commit in the list)
$latestCommit = $shelveSetinfo[0]
$commitSha = $latestCommit.sha  # Commit SHA
$commitMessage = $latestCommit.commit.message  # Commit message
$commitAuthor = $latestCommit.commit.author.name  # Author of the commit
$commitDate = $latestCommit.commit.author.date  # Date of the commit

# Get Changed Files in the Commit
$commitURL = "$orgURL/repos/$repoOwner/$repoName/commits/$commitSha"  # Get detailed commit info
$commitInfo = Invoke-RestMethod -Uri $commitURL -Method Get -ContentType "application/json" -Headers $header
$changedFiles = $commitInfo.files | ForEach-Object { $_.filename }  # Extract the changed files in the commit

# Store Details in an Array
$commitDetails = @{
    CommitSHA     = $commitSha
    CommitMessage = $commitMessage
    CommitAuthor  = $commitAuthor
    CommitDate    = $commitDate
    ChangedFiles  = $changedFiles
}

# Convert to JSON and Save to a File (commit-details.json)
$commitDetails | ConvertTo-Json -Depth 0 | Out-File -Encoding utf8 "commit-details.json"

Write-Host "Commit details saved to commit-details.json"
