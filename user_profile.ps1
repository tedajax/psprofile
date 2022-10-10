# Use this file to run your own startup commands

## Prompt Customization
<#
.SYNTAX
    <PrePrompt><CMDER DEFAULT>
    λ <PostPrompt> <repl input>
.EXAMPLE
    <PrePrompt>N:\Documents\src\cmder [master]
    λ <PostPrompt> |
#>

[ScriptBlock]$PrePrompt = {

}

# Replace the cmder prompt entirely with this.
# [ScriptBlock]$CmderPrompt = {}

[ScriptBlock]$PostPrompt = {

}

## <Continue to add your own>

# # Delete default powershell aliases that conflict with bash commands
# if (get-command git) {
#     del -force alias:cat
#     del -force alias:clear
#     del -force alias:cp
#     del -force alias:diff
#     del -force alias:echo
#     del -force alias:kill
#     del -force alias:ls
#     del -force alias:mv
#     del -force alias:ps
#     del -force alias:pwd
#     del -force alias:rm
#     del -force alias:sleep
#     del -force alias:tee
# }


function Enable-VCEnv($version) {
    $vc_version = "-latest"
    if ($version -eq "2022") {
        $vc_version = "-version 17"
    }
    elseif ($version -eq "2019") {
        $vc_version = "-version 16"
    }
    elseif ($version -eq "2017") {
        $vc_version = "-version 15"
    }

    $vswhere_path = "vswhere.exe"

    if (!(Get-Command $vswhere_path -ErrorAction SilentlyContinue)) {
        # Try to find vswhere in visual studio install location
        $vswhere_path = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
        if (!(Test-Path -LiteralPath $vswhere_path -PathType Leaf)) {
            # Try to find in chocolatey install location
            $vswhere_path = "${env:ProgramData}\chocolatey\lib\vswhere\tools\vswhere.exe"
        }
        if (!(Test-Path -LiteralPath $vswhere_path -PathType Leaf)) {
            # Give up
            Write-Output "Unable to find vswhere.exe"
            exit
        }
    }

    Write-Output "Using vswhere.exe located at ""$vswhere_path"""

    $vswhere_path = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"
    $vswhere_cmd = "& ""$vswhere_path"" {0} -property installationPath" -f $vc_version

    Write-Host $vswhere_cmd
    $vswhere_result = Invoke-Expression $vswhere_cmd

    if ($vswhere_result -is [array]) {
        $vswhere_result = $vswhere_result[0]
    }

    Write-Host $vc_version
    Write-Host $vswhere_result

    $vcvarsall_path = """{0}\VC\Auxiliary\Build\vcvarsall.bat""" -f $vswhere_result

    cmd /c "$vcvarsall_path amd64&set" |
    ForEach-Object {
        if ($_ -match "=") {
            $v = $_.split("=") set-item -force -path "ENV:\$($v[0])" -value "$($v[1])"
        }
        Write-Host $_
    }
}

function Get-GitStatus() { git status }
function p8() { Push-Location $env:PICO8_DIR }

$env:PICO8_DIR = "$env:APPDATA\pico-8\carts"

Set-Alias gs Get-GitStatus
