# deploy.ps1
# Voter App API Deployment Script (PowerShell)
Write-Host "🚀 Starting Voter App API deployment..."

# Ensure we run from script directory
if ($PSScriptRoot) { Set-Location $PSScriptRoot }

# Check if virtual environment exists
if (-not (Test-Path -Path ".\venv" -PathType Container)) {
    Write-Host "📦 Creating virtual environment..."
    # Use whatever 'python' resolves to on the machine
    python -m venv venv
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create virtual environment. Ensure Python is installed and on PATH."
        exit 1
    }
} else {
    Write-Host "✅ Virtual environment already exists."
}

# Activate virtual environment
$activateScript = Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "venv") -ChildPath "Scripts\Activate.ps1"
if (Test-Path $activateScript) {
    Write-Host "🔧 Activating virtual environment..."
    # Execute the Activate.ps1 in the current session
    & $activateScript
} else {
    Write-Warning "Activation script not found at '$activateScript'. You may need to activate manually: .\venv\Scripts\Activate.ps1"
}

# Install dependencies
if (-not (Test-Path -Path ".\requirements.txt" -PathType Leaf)) {
    Write-Warning "requirements.txt not found in the current directory."
} else {
    Write-Host "📥 Installing dependencies..."
    # Use python -m pip to ensure pip from the active python is used
    python -m pip install --upgrade pip
    python -m pip install -r requirements.txt
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Dependency installation failed."
        exit 1
    }
}

# Set environment variables for production (process-level)
Write-Host "🔒 Setting environment variables..."
$Env:ENV   = "production"
$Env:DEBUG = "False"
$Env:HOST  = "0.0.0.0"
$Env:PORT  = "8080"

Write-Host "🌐 Starting API server..."
Write-Host "API will be available at http://localhost:8080"
Write-Host "Press Ctrl+C to stop the server"

try {
    # Run the application (this will block until the process ends)
    python main.py
} catch {
    Write-Error "Failed to start the server: $_"
    exit 1
}
