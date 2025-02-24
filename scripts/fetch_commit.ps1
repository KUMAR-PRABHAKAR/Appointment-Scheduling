name: Fetch Commit Details

on:
  push:
    branches:
      -main  # ✅ Corrected YAML spacing

jobs:
  fetch_commit_details:
    runs-on: windows-latest  # ✅ Using Windows for .NET Framework project

    steps:
      -name: Checkout Repository
        uses: actions/checkout@v3
        with:
          fetch-depth: 0  # ✅ Fetch full commit history

      -name: Set up PowerShell
        run: pwsh --version  # ✅ Verify PowerShell is installed

      -name: Fetch Commit Details
        run: pwsh -ExecutionPolicy Bypass -File ./scripts/fetch_commit.ps1
        env:
          MY_GITHUB_TOKEN: ${secrets.MY_GITHUB_TOKEN}  # ✅ Use GitHub token for API requests

      -name: Upload Commit Details
        uses: actions/upload-artifact@v4
        with:
          name: commit-details
          path: ./commit-details.json  # ✅ Correct indentation and path

      -name: Print Commit Details
        run: type ./commit-details.json  # ✅ Changed `cat` to `type` for Windows compatibility
