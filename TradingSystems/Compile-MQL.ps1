Param(
    [switch]$help,     # Flag to display help information
    [switch]$test,     # Test compilation flag
    [string]$target    # Name of the target system (e.g., "Moving.Time.EA")
)

# Display help if --help flag is provided
if ($help) {
    Write-Host "Compile-TradingSystem.ps1" -ForegroundColor Cyan
    Write-Host "This script compiles a specified MQL5 trading system file, validates the result," `
        + "and optionally moves the compiled file to a designated output folder." -ForegroundColor White
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor Cyan
    Write-Host "  -target [string]      Specify the trading system's name (e.g., 'Moving.Time.EA')." `
        + " The script searches for the 'TradingSystem.mq5' file in the corresponding directory."
    Write-Host "  -test                 Perform a test compilation without creating or copying the output file."
    Write-Host "  -help                 Display this help message and exit."
    Write-Host ""
    Write-Host "Environment Variables (defined in .env):" -ForegroundColor Cyan
    Write-Host "  OUTPUT_PATH           Path where the compiled files will be saved."
    Write-Host "  METAEDITOR_PATH       Path to the MetaEditor executable."
    Write-Host "  INCLUDE_PATH          Path to the include directory for the MetaEditor compiler."
    Write-Host ""
    Write-Host "Usage Examples:" -ForegroundColor Cyan
    Write-Host "  Test compilation only:" -ForegroundColor White
    Write-Host "    .\Compile-TradingSystem.ps1 -target 'MovingAvarage.Time.EA' -test" -ForegroundColor Gray
    Write-Host "  Full compilation:" -ForegroundColor White
    Write-Host "    .\Compile-TradingSystem.ps1 -target 'MovingAvarage.Time.EA'" -ForegroundColor Gray
    Write-Host ""
    Write-Host ""
    exit
}

# Load environment variables from .env file
$envFile = ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match "^(.*?)=(.*?)$") {
            [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2])
        }
    }
} else {
    Write-Host "ERROR: .env file not found!" -ForegroundColor Red
    exit
}

# Retrieve paths from environment variables
$Output = [System.Environment]::GetEnvironmentVariable("OUTPUT_PATH")
$MetaEditorPath = [System.Environment]::GetEnvironmentVariable("METAEDITOR_PATH")
$IncludePath = [System.Environment]::GetEnvironmentVariable("INCLUDE_PATH")

if (-not $Output -or -not $MetaEditorPath -or -not $IncludePath) {
    Write-Host "ERROR: Missing required paths in the .env file!" -ForegroundColor Red
    exit
}

# Ensure target is provided
if (-not $target) {
    Write-Host "ERROR: target parameter is required!" -ForegroundColor Red
    exit
}

# Define file and directory structure
$ScriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetDirectory = Join-Path $ScriptDirectory $target
$FileToCompile = Join-Path $TargetDirectory "TradingSystem.mq5"
$CompiledFile = Join-Path $TargetDirectory "TradingSystem.ex5"

# Validate directory and file existence
if (-not (Test-Path $TargetDirectory)) {
    Write-Host "ERROR: target directory not found: $TargetDirectory" -ForegroundColor Red
    exit
}
if (-not (Test-Path $FileToCompile)) {
    Write-Host "ERROR: File not found: $FileToCompile" -ForegroundColor Red
    exit
}

# Clear the terminal and log file setup
Clear-Host
$LogFile = "last-build.log"
Write-Host "Compiling file........: $FileToCompile"

# Check if the file path contains spaces
if ($FileToCompile.Contains(" ")) {
    Write-Host "ERROR: Filename or path contains spaces!" -ForegroundColor Red
    exit
}

# Compile using MetaEditor
Write-Host "Compiling with MetaEditor..."
& $MetaEditorPath /compile:"$FileToCompile" /log:"$LogFile" /inc:"$IncludePath" | Out-Null

# Process the log file
$Log = Get-Content -Path $LogFile | Where-Object {$_ -ne ""} | Select-Object -Skip 1
$WhichColor = "Red"
$Log | ForEach-Object { if ($_.Contains(" 0 errors, 0 warnings")) { $WhichColor = "Green" } }
$Log | ForEach-Object {
    if (-Not $_.Contains("information:")) {
        Write-Host $_ -ForegroundColor $WhichColor
    }
}

# Handle compilation failure
if ($WhichColor -eq "Red") {
    Write-Host "Compilation failed! Check the log file for errors: $LogFile" -ForegroundColor Red
    exit
}

# Exit if test compilation is requested
if ($test) {
    if (Test-Path $CompiledFile) {
        Remove-Item -Path $CompiledFile -Force
        Write-Host "Test compilation completed, temporary compiled file deleted." -ForegroundColor Green
    }
    exit
}

# Create output folder if it doesn't exist
$FinalOutputFolder = Join-Path $Output $target
if (!(Test-Path $FinalOutputFolder)) {
    New-Item -Path $FinalOutputFolder -ItemType Directory | Out-Null
}

# Generate unique identifier and copy the compiled file
$UniqueId = Get-Date -Format "yyyyMMdd.HHmmss"
$FinalEx5Path = Join-Path $FinalOutputFolder ($target + "_" + $UniqueId + ".ex5")

if (Test-Path $CompiledFile) {
    Copy-Item -Path $CompiledFile -Destination $FinalEx5Path
    Write-Host "Successfully created:" -ForegroundColor Green
    Write-Host $FinalEx5Path -ForegroundColor Green

    # Delete the compiled file from the Target directory
    Remove-Item -Path $CompiledFile -Force
} else {
    Write-Host "ERROR: Compiled file not found: $CompiledFile" -ForegroundColor Red
    exit
}
