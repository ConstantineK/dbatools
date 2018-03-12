﻿$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"


Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    BeforeAll {
        $dbs = $testlastbackup, "dbatoolsci_lildb", "dbatoolsci_testrestore", "dbatoolsci_singlerestore"
        $null = Get-Database -SqlInstance $script:instance2 -Database $dbs | Remove-Database -Confirm:$false
        $server = Connect-Instance -SqlInstance $script:instance2
        $random = Get-Random
        $testlastbackup = "dbatoolsci_testlastbackup$random"
        $dbs = $testlastbackup, "dbatoolsci_lildb", "dbatoolsci_testrestore", "dbatoolsci_singlerestore"

        foreach ($db in $dbs) {
            $server.Query("CREATE DATABASE $db")
            $server.Query("ALTER DATABASE $db SET RECOVERY FULL WITH NO_WAIT")
            $server.Query("CREATE TABLE [$db].[dbo].[Example] (id int identity, name nvarchar(max))")
            $server.Query("INSERT INTO [$db].[dbo].[Example] values ('sample')")
        }

    }
    AfterAll {
        # these for sure
        Get-Database -SqlInstance $script:instance2 -Database $dbs | Remove-Database -Confirm:$false
        # those just in case test-dbalastbackup didn't cooperate
        Get-Database -SqlInstance $script:instance2 | Where-Object Name -like 'dbatools-testrestore-dbatoolsci_*' | Remove-Database -Confirm:$false
        # see "Restores using a specific path"
        Get-ChildItem -Path C:\Temp\dbatools-testrestore-dbatoolsci_singlerestore* | Remove-Item
    }
    Context "Setup restores and backups on the local drive for Test-LastBackup" {
        Get-Database -SqlInstance $script:instance2 -Database $dbs | Backup-Database -Type Database
        $server.Query("INSERT INTO [$testlastbackup].[dbo].[Example] values ('sample')")
        Get-Database -SqlInstance $script:instance2 -Database $testlastbackup | Backup-Database -Type Differential
        $server.Query("INSERT INTO [$testlastbackup].[dbo].[Example] values ('sample1')")
        Get-Database -SqlInstance $script:instance2 -Database $testlastbackup | Backup-Database -Type Differential
        $server.Query("INSERT INTO [$testlastbackup].[dbo].[Example] values ('sample2')")
        Get-Database -SqlInstance $script:instance2 -Database $testlastbackup | Backup-Database -Type Log
        $server.Query("INSERT INTO [$testlastbackup].[dbo].[Example] values ('sample3')")
        Get-Database -SqlInstance $script:instance2 -Database $testlastbackup | Backup-Database -Type Log
        $server.Query("INSERT INTO [$testlastbackup].[dbo].[Example] values ('sample4')")
    }

    Context "Test a single database" {
        $results = Test-LastBackup -SqlInstance $script:instance2 -Database $testlastbackup

        It "Should return success" {
            $results.RestoreResult | Should Be "Success"
            $results.DbccResult | Should Be "Success"
        }
    }

    Context "Testing the whole instance" {
        $results = Test-LastBackup -SqlInstance $script:instance2 -ExcludeDatabase tempdb
        It "Should be more than 3 databases" {
            $results.count | Should BeGreaterThan 3
        }
    }

    Context "Restores using a specific path" {
        $null = Get-Database -SqlInstance $script:instance2 -Database "dbatoolsci_singlerestore" | Backup-Database
        $null = Test-LastBackup -SqlInstance $script:instance2 -Database "dbatoolsci_singlerestore" -DataDirectory C:\Temp -LogDirectory C:\Temp -NoDrop
        $results = Get-DatabaseFile -SqlInstance $script:instance2 -Database "dbatools-testrestore-dbatoolsci_singlerestore"
        It "Should match C:\Temp" {
            ('C:\Temp\dbatools-testrestore-dbatoolsci_singlerestore.mdf' -in $results.PhysicalName) | Should Be $true
            ('C:\Temp\dbatools-testrestore-dbatoolsci_singlerestore_log.ldf' -in $results.PhysicalName) | Should Be $true
        }
    }
}
