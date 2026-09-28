[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$jdkRoot = 'C:\Users\Bernardo Finkler\AppData\Local\CompyTooling\temurin-21-complete\jdk-21.0.12.1+1'
$javaExe = Join-Path $jdkRoot 'bin\java.exe'

if (-not (Test-Path -LiteralPath $javaExe -PathType Leaf)) {
  throw "JDK 21 não encontrado em '$javaExe'."
}

$previousJavaHome = $env:JAVA_HOME
$previousPath = $env:Path
$exitCode = 1

try {
  $env:JAVA_HOME = $jdkRoot
  $env:Path = "$(Join-Path $jdkRoot 'bin');$previousPath"

  Write-Host 'Java selecionado para esta execução:'
  $versionOutput = (& $javaExe -version 2>&1 | Out-String).Trim()
  $versionExitCode = $LASTEXITCODE
  Write-Host $versionOutput
  if ($versionExitCode -ne 0 -or $versionOutput -notmatch 'version "21(?:\.|"|\+)') {
    throw "A verificação java -version falhou ou não confirmou JDK 21 (exit code $versionExitCode)."
  }

  Push-Location $repoRoot
  try {
    & npm test --prefix (Join-Path $repoRoot 'tools\firestore-rules-tests')
    $exitCode = $LASTEXITCODE
  }
  finally {
    Pop-Location
  }
}
finally {
  $env:JAVA_HOME = $previousJavaHome
  $env:Path = $previousPath
}

exit $exitCode
