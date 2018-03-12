$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {

    BeforeAll {
        $server = Connect-Instance -SqlInstance $script:instance2
        $random = Get-Random
        $dbname = "dbatoolsci_getlastbackup$random"
        $server.Query("CREATE DATABASE $dbname")
        $server.Query("ALTER DATABASE $dbname SET RECOVERY FULL WITH NO_WAIT")
        $backupdir = Join-Path $server.BackupDirectory $dbname
        if (-not (Test-Path $backupdir -PathType Container)) {
            $null = New-Item -Path $backupdir -ItemType Container
        }
    }

    AfterAll {
        $null = Get-Database -SqlInstance $script:instance2 -Database $dbname | Remove-Database -Confirm:$false
        Remove-Item -Path $backupdir -Recurse -Force -ErrorAction SilentlyContinue
    }

    Context "Get null history for database" {
        $results = Get-LastBackup -SqlInstance $script:instance2 -Database $dbname
        It "doesn't have any values for last backups because none exist yet" {
            $results.LastFullBackup | Should Be $null
            $results.LastDiffBackup | Should Be $null
            $results.LastLogBackup | Should Be $null
        }
    }

    $yesterday = (Get-Date).AddDays(-1)
    $null = Get-Database -SqlInstance $script:instance2 -Database $dbname | Backup-Database -BackupDirectory $backupdir
    $null = Get-Database -SqlInstance $script:instance2 -Database $dbname | Backup-Database -BackupDirectory $backupdir -Type Differential
    $null = Get-Database -SqlInstance $script:instance2 -Database $dbname | Backup-Database -BackupDirectory $backupdir -Type Log

    Context "Get last history for single database" {
        $results = Get-LastBackup -SqlInstance $script:instance2 -Database $dbname
        It "returns a date within the proper range" {
            [datetime]$results.LastFullBackup -gt $yesterday | Should Be $true
            [datetime]$results.LastDiffBackup -gt $yesterday | Should Be $true
            [datetime]$results.LastLogBackup -gt $yesterday | Should Be $true
        }
    }

    Context "Get last history for all databases" {
        $results = Get-LastBackup -SqlInstance $script:instance2
        It "returns more than 3 databases" {
            $results.count -gt 3 | Should Be $true
        }
    }

    Context "Get last history for one split database" {
        It "supports multi-file backups" {
            $null = Backup-Database -SqlInstance $script:instance2 -Database $dbname -FileCount 4
            $results = Get-LastBackup -SqlInstance $script:instance2 -Database $dbname | Select-Object -First 1
            $results.LastFullBackup.GetType().Name | Should be "DbaDateTime"
        }
    }
}