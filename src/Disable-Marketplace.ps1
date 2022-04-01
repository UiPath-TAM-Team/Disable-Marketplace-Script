<#
.SYNOPSIS
    Disable Marketplace tab in Assistant.

.EXAMPLE
    PS> .\Disable-Marketplace.ps1
#>

Function WriteLog {
    Param (
        [string] $Message,
        [switch] $Err
    )
    $LogFile = "Disable-Marketplace.log"
    If (!(Test-Path $LogFile)) {
        New-Item $LogFile
    }
    $Now = Get-Date -Format "HH:mm:ss"
    $Line = "$Now`t$Message"
    $Line | Add-Content $LogFile -Encoding UTF8
    If ($Err) {
        Write-Host $Line -ForegroundColor Red
    } Else {
        Write-Host $Line
    }
}

WriteLog "STARTED: Disable-Marketplace.ps1."

$SettingsFile = $env:USERPROFILE + "\AppData\Roaming\UiPath\agent-settings.json"
Try {    
    $BackupFile = $env:USERPROFILE + "\AppData\Roaming\UiPath\agent-settings-backup.json"
    Copy-Item -Path $SettingsFile -Destination $BackupFile
} Catch {
    WriteLog -Err "ERROR: Creating backup of settings file."
}

$Match = '    "agent": {'
$Add = @()
$Add += '		"defaultNugetWidgetConfig": {'
$Add += '			"widgets": {},'
$Add += '			"enableOldWidgets": true,'
$Add += '			"enableFallbackFeed": true,'
$Add += '			"expires": "2100-01-01T00:00:00.000Z",'
$Add += '			"policy": "Assistant with Marketplace tab disabled."'
$Add += '		},'
Try {
    $Reader = [IO.File]::OpenText($SettingsFile)
    $Found = $false
    $Text = while ($Reader.Peek() -ge 0) {
        $Line = $Reader.ReadLine()
        $Line
        if ($Line -eq $Match) {
            $Found = $true
            $Add
        }
    }
    $Reader.Close()
    if ($Found) {
        WriteLog "INFO: Found agent line in settings file."
        $Text | Where-Object { $_ } | Set-Content $SettingsFile
    } else {
        WriteLog "ERROR: Agent line not found in settings file."
    }
} Catch {
    WriteLog -Err "ERROR: Configuring settings file."
}

WriteLog "COMPLETED: Disable-Marketplace.ps1."
WriteLog "--------------------------------------------------"