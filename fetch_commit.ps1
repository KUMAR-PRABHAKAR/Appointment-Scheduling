# Set GitHub API URL
$orgURL = "https://api.github.com"
$repoOwner = "KUMAR-PRABHAKAR"  # Change this to your GitHub username
$repoName = "Appointment-Scheduling"
$branchName = "main"

# GitHub Token (from Secrets in GitHub Actions)
$myToken = "{{secrets.MY_GITHUB_TOKEN}}"


# Set Headers for API Request
$header = @{
    Authorization = "token $($myToken)"
    Accept        = "application/vnd.github.v3+json"
}

# Get Latest Commit SHA from the Main Branch
$shelveSetURL = "$orgURL/repos/$repoOwner/$repoName/git/refs/heads/$branchName"
$shelveSetinfo = Invoke-RestMethod -Uri $shelveSetURL -Method Get -ContentType "application/json" -Headers $header
$commitSha = $shelveSetinfo.object.sha

Write-Host "Latest Commit SHA: $commitSha"

# Get Commit Details
$commitURL = "$orgURL/repos/$repoOwner/$repoName/commits/$commitSha"
$commitinfo = Invoke-RestMethod -Uri $commitURL -Method Get -ContentType "application/json" -Headers $header

# Output Commit Information
Write-Host "Commit Message: $($commitinfo.commit.message)"
Write-Host "Commit Author: $($commitinfo.commit.author.name)"
Write-Host "Commit Date: $($commitinfo.commit.author.date)"

# Optional: Save Commit Details to a File
$commitinfo | ConvertTo-Json | Out-File "commit-details.json"
