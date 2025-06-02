Param(
    [switch]$help,            # Flag to display help information
    [switch]$test,            # Flag for test compilation
    [string]$target,          # Name of the target system (e.g., "Moving.Time.EA")
    [string]$n,               # Optional custom name for output directory and file
    [string]$include          # Name of a folder to include during compilation
)

# Display help if --help flag is provided
if ($help) {
    Write-Host "`n=== Compile-TradingSystem.ps1 Help ===" -ForegroundColor Cyan
    Write-Host "This script compiles a specified MQL5 trading system file, validates the result," `
        "and optionally moves the compiled file to a designated output folder." -ForegroundColor White
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor Cyan
    Write-Host "  -help                 Display this help message and exit." -ForegroundColor White
    Write-Host "  -target [string]      Specify the trading system's name (e.g., 'Moving.Time.EA')." `
        "The script searches for 'TradingSystem.mq5' in the corresponding directory." -ForegroundColor White
    Write-Host "  -include [string]     Name of a folder to include during compilation." -ForegroundColor White
    Write-Host "  -n [string]           Custom name for output folder and prefix of compiled file." `
        "- no spaces allowed." -ForegroundColor White
    Write-Host "  -test                 Perform a test compilation without creating or copying the output file." -ForegroundColor White
    Write-Host ""
    Write-Host "Environment Variables (defined in .env):" -ForegroundColor Cyan
    Write-Host "  OUTPUT_PATH           Path where the compiled files will be saved." -ForegroundColor White
    Write-Host "  METAEDITOR_PATH       Path to the MetaEditor executable." -ForegroundColor White
    Write-Host ""
    Write-Host "Usage Examples:" -ForegroundColor Cyan
    Write-Host "  Test compilation only:" -ForegroundColor White
    Write-Host "    ./compile-trading-system.ps1 -target 'RangeBrakeout' -include 'AdditionalParams' -n 'RangeBrakeout' -test" -ForegroundColor Gray
    Write-Host "  Full compilation:" -ForegroundColor White
    Write-Host "    ./compile-trading-system.ps1 -target 'RangeBrakeout' -include 'AdditionalParams' -n 'RangeBrakeout'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    exit
}

# Validate the $n parameter
if ($n -and $n.Contains(" ")) {
    Write-Host "[ERROR] The parameter 'n' cannot contain spaces!" -ForegroundColor Red
    exit
}

Write-Host "[INFO] Starting Compile-TradingSystem.ps1 script..." -ForegroundColor Cyan

# Load environment variables from .env file
$envFile = ".env"
Write-Host "[INFO] Checking for .env file at $envFile" -ForegroundColor Cyan
if (Test-Path $envFile) {
    Write-Host "[INFO] .env file found. Loading environment variables..." -ForegroundColor Green
    Get-Content $envFile | ForEach-Object {
        if ($_ -match "^(.*?)=(.*?)$") {
            $key   = $matches[1]
            $value = $matches[2]
            [System.Environment]::SetEnvironmentVariable($key, $value)
            Write-Host "[DEBUG] Loaded ENV: $key = $value" -ForegroundColor DarkGray
        }
    }
} else {
    Write-Host "[ERROR] .env file not found! Aborting." -ForegroundColor Red
    exit
}

# Retrieve paths from environment variables
$Output         = [System.Environment]::GetEnvironmentVariable("OUTPUT_PATH")
$MetaEditorPath = [System.Environment]::GetEnvironmentVariable("METAEDITOR_PATH")
Write-Host "[INFO] OUTPUT_PATH = $Output" -ForegroundColor Cyan
Write-Host "[INFO] METAEDITOR_PATH = $MetaEditorPath" -ForegroundColor Cyan

if (-not $Output -or -not $MetaEditorPath) {
    Write-Host "[ERROR] Missing required OUTPUT_PATH or METAEDITOR_PATH in .env! Aborting." -ForegroundColor Red
    exit
}

# Ensure target is provided
if (-not $target) {
    Write-Host "[ERROR] 'target' parameter is required! Aborting." -ForegroundColor Red
    exit
}
Write-Host "[INFO] Target parameter = $target" -ForegroundColor Cyan

# Define file and directory structure
$ScriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetDirectory = Join-Path $ScriptDirectory $target
$FileToCompile   = Join-Path $TargetDirectory "TradingSystem.mq5"
$CompiledFile    = Join-Path $TargetDirectory "TradingSystem.ex5"

Write-Host "[INFO] Script directory = $ScriptDirectory" -ForegroundColor Cyan
Write-Host "[INFO] Target directory = $TargetDirectory" -ForegroundColor Cyan
Write-Host "[INFO] File to compile = $FileToCompile" -ForegroundColor Cyan

# Validate directory and file existence
if (-not (Test-Path $TargetDirectory)) {
    Write-Host "[ERROR] Target directory not found: $TargetDirectory" -ForegroundColor Red
    exit
}
if (-not (Test-Path $FileToCompile)) {
    Write-Host "[ERROR] File not found: $FileToCompile" -ForegroundColor Red
    exit
}

# Clear the terminal and prepare log file
$LogFile = Join-Path $ScriptDirectory "last-build.log"
Write-Host "[INFO] Log file will be written to: $LogFile" -ForegroundColor Cyan

# Check if the file path contains spaces
if ($FileToCompile.Contains(" ")) {
    Write-Host "[ERROR] Filename or path contains spaces! Aborting." -ForegroundColor Red
    exit
}

# If an include folder name is provided, copy it into "Include\" first
if ($include) {
    Write-Host "[INFO] Include folder parameter provided: $include" -ForegroundColor Cyan
    $SourceFolder      = Join-Path $TargetDirectory $include
    $DestIncludeFolder = Join-Path $ScriptDirectory "Include\$include"
    Write-Host "[INFO] Source include folder = $SourceFolder" -ForegroundColor Cyan
    Write-Host "[INFO] Destination include folder = $DestIncludeFolder" -ForegroundColor Cyan

    if (-not (Test-Path $SourceFolder)) {
        Write-Host "[ERROR] Source folder to copy does not exist: $SourceFolder" -ForegroundColor Red
        exit
    }

    Write-Host "[INFO] Copying include folder into 'Include\'..." -ForegroundColor Green
    Copy-Item -Path $SourceFolder -Destination $DestIncludeFolder -Recurse -Force
    Write-Host "[DEBUG] Copy completed: $SourceFolder -> $DestIncludeFolder" -ForegroundColor DarkGray
}

try {
    # Compile using MetaEditor
    Write-Host "[INFO] Starting compilation with MetaEditor..." -ForegroundColor Cyan
    if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform(
        [System.Runtime.InteropServices.OSPlatform]::Linux)) {
        Write-Host "[DEBUG] Detected OS: Linux. Using Wine invocation." -ForegroundColor DarkGray
        $wineCmd = @(
            $MetaEditorPath,
            "/compile:$FileToCompile",
            "/log:$LogFile",
            "/inc:Z:/$ScriptDirectory"
        )
        Write-Host "[DEBUG] Wine command: wine start /unix $($wineCmd -join ' ')" -ForegroundColor DarkGray
        & wine start /unix $wineCmd | Out-Null
        Write-Host "[INFO] MetaEditor (via Wine) launched." -ForegroundColor Green
    }
    else {
        Write-Host "[DEBUG] Detected OS: Windows. Running MetaEditor directly." -ForegroundColor DarkGray
        $nativeCmd = @(
            $MetaEditorPath,
            "/compile:$FileToCompile",
            "/log:$LogFile",
            "/inc:$ScriptDirectory"
        )
        Write-Host "[DEBUG] Native command: $($nativeCmd -join ' ')" -ForegroundColor DarkGray
        & $nativeCmd | Out-Null
        Write-Host "[INFO] MetaEditor launched natively." -ForegroundColor Green
    }

    # Wait 2 seconds to ensure the log file is fully written
    Write-Host "[INFO] Waiting 1 second for log file write..." -ForegroundColor Cyan
    Start-Sleep -Seconds 1

    # Process the log file
    Write-Host "[INFO] Reading and processing log file..." -ForegroundColor Cyan
    $Log = Get-Content -Path $LogFile | Where-Object { $_ -ne "" } | Select-Object -Skip 1
    $WhichColor = "Red"
    $Log | ForEach-Object {
        if ($_.Contains(" 0 errors, 0 warnings")) { $WhichColor = "Green" }
    }
    $Log | ForEach-Object {
        if (-not $_.Contains("information:")) {
            Write-Host "[INFO] $_" -ForegroundColor $WhichColor
        }
    }

    # Handle compilation failure
    if ($WhichColor -eq "Red") {
        Write-Host "[ERROR] Compilation failed! Check the log file for details: $LogFile" -ForegroundColor Red
        exit
    }
    Write-Host "[INFO] Compilation succeeded with no errors or warnings." -ForegroundColor Green

    # Exit if test compilation is requested
    if ($test) {
        Write-Host "[INFO] Test mode enabled. Removing temporary .ex5 (if exists) and exiting." -ForegroundColor Cyan
        if (Test-Path $CompiledFile) {
            Remove-Item -Path $CompiledFile -Force
            Write-Host "[DEBUG] Removed file: $CompiledFile" -ForegroundColor DarkGray
        }
        exit
    }

    # Create output folder if it doesn't exist
    $FinalOutputFolder = if ($n) { Join-Path $Output $n } else { Join-Path $Output $target }
    Write-Host "[INFO] Final output folder = $FinalOutputFolder" -ForegroundColor Cyan
    if (-not (Test-Path $FinalOutputFolder)) {
        Write-Host "[INFO] Creating final output folder..." -ForegroundColor Green
        New-Item -Path $FinalOutputFolder -ItemType Directory | Out-Null
        Write-Host "[DEBUG] Created folder: $FinalOutputFolder" -ForegroundColor DarkGray
    }

    # Generate unique identifier and copy the compiled file
    $UniqueId = Get-Date -Format "yyyyMMdd.HHmmss"
    if ($n) {
        $FinalEx5Name = "$n`_$UniqueId.ex5"
    } else {
        $FinalEx5Name = "$target`_$UniqueId.ex5"
    }
    $FinalEx5Path = Join-Path $FinalOutputFolder $FinalEx5Name
    Write-Host "[INFO] Final .ex5 filename = $FinalEx5Name" -ForegroundColor Cyan

    if (Test-Path $CompiledFile) {
        Write-Host "[INFO] Copying compiled file to final destination..." -ForegroundColor Green
        Copy-Item -Path $CompiledFile -Destination $FinalEx5Path
        Write-Host "[SUCCESS] Successfully created: $FinalEx5Path" -ForegroundColor Green

        # Delete the compiled file from the Target directory
        Write-Host "[INFO] Removing temporary compiled file: $CompiledFile" -ForegroundColor Cyan
        Remove-Item -Path $CompiledFile -Force
    }
    else {
        Write-Host "[ERROR] Compiled file not found at expected location: $CompiledFile" -ForegroundColor Red
        exit
    }
}
finally {
    # Always remove the copied folder from "Include\" after compilation (success or fail)
    if ($include) {
        $DestIncludeFolder = Join-Path $ScriptDirectory "Include\$include"
        Write-Host "[INFO] Cleaning up include folder: $DestIncludeFolder" -ForegroundColor Cyan
        if (Test-Path $DestIncludeFolder) {
            Remove-Item -Path $DestIncludeFolder -Recurse -Force
            Write-Host "[DEBUG] Removed include folder: $DestIncludeFolder" -ForegroundColor DarkGray
        } else {
            Write-Host "[DEBUG] No include folder to remove." -ForegroundColor DarkGray
        }
    }
    Write-Host "[INFO] Script execution completed." -ForegroundColor Cyan
}
