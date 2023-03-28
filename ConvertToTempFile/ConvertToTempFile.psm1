#Requires -Version 3

# From https://serverfault.com/questions/688645/powershells-equivalent-to-bashs-process-substitution
# Author mkelement

# Define a succinct alias.
  set-alias cf ConvertTo-TempFile
  function ConvertTo-TempFile {
    [CmdletBinding(DefaultParameterSetName='Cleanup')]
    param(
        [Parameter(ParameterSetName='Standard', Mandatory=$true, Position=0)]
        [ScriptBlock] $ScriptBlock
      , [Parameter(ParameterSetName='Standard', Position=1)]
        [string] $LiteralPath
      , [Parameter(ParameterSetName='Standard')]
        [string] $Extension
      , [Parameter(ParameterSetName='Standard')]
        [switch] $BOM
    )

    $prevFilePath = Test-Path variable:__cttfFilePath
    if ($PSCmdlet.ParameterSetName -eq 'Cleanup') {
      if ($prevFilePath) { 
        Write-Verbose "Removing temp. file: $__cttfFilePath"
        Remove-Item -ErrorAction SilentlyContinue $__cttfFilePath
        Remove-Variable -Scope Script  __cttfFilePath
      } else {
        Write-Verbose "Nothing to clean up."
      }
    } else { # script block specified
      if ($Extension -and $Extension -notlike '.*') { $Extension = ".$Extension" }
      if ($LiteralPath) {
        # Since we'll be using a .NET framework classes directly, 
        # we must sync .NET's notion of the current dir. with PowerShell's.
        [Environment]::CurrentDirectory = $pwd
        if ([System.IO.Directory]::Exists($LiteralPath)) { 
          $script:__cttfFilePath = [IO.Path]::Combine($LiteralPath, [IO.Path]::GetRandomFileName() + $Extension)
          Write-Verbose "Creating file with random name in specified folder: '$__cttfFilePath'."
        } else { # presumptive path to a *file* specified
          if (-not [System.IO.Directory]::Exists((Split-Path $LiteralPath))) {
            Throw "Output folder '$(Split-Path $LiteralPath)' must exist."
          }
          $script:__cttfFilePath = $LiteralPath
          Write-Verbose "Using explicitly specified file path: '$__cttfFilePath'."
        }
      } else { # Create temp. file in the user's temporary folder.
        if (-not $prevFilePath) { 
          if ($Extension) {
            $script:__cttfFilePath = [IO.Path]::Combine([IO.Path]::GetTempPath(), [IO.Path]::GetRandomFileName() + $Extension)
          } else {
            $script:__cttfFilePath = [IO.Path]::GetTempFilename() 
          }
          Write-Verbose "Creating temp. file: $__cttfFilePath"
        } else {
          Write-Verbose "Reusing temp. file: $__cttfFilePath"      
        }
      }
      if (-not $BOM) { # UTF8 file *without* BOM
        # Note: Out-File, sadly, doesn't support creating UTF8-encoded files 
        #       *without a BOM*, so we must use the .NET framework.
        #       [IO.StreamWriter] by default writes UTF-8 files without a BOM.
        $sw = New-Object IO.StreamWriter $__cttfFilePath
        try {
            . $ScriptBlock | Out-String -Stream | % { $sw.WriteLine($_) }
        } finally { $sw.Close() }
      } else { # UTF8 file *with* BOM
        . $ScriptBlock | Out-File -Encoding utf8 $__cttfFilePath
      }
      return $__cttfFilePath
    }
  }