$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Recovery model is correctly identified" {
        $results = Get-DbRecoveryModel -SqlInstance $script:instance2 -Database master

        It "returns a single database" {
            $results.Count | Should Be 1
        }

        It "returns the correct recovery model" {
            $results.RecoveryModel -eq 'Simple' | Should Be $true
        }

        $results = Get-DbRecoveryModel -SqlInstance $script:instance2

        It "returns accurate number of results" {
            $results.Count -ge 4 | Should Be $true
        }
    }
    Context "RecoveryModel parameter works" {
        BeforeAll {
            $server = Connect-Instance -SqlInstance $script:instance2
            $dbname = "dbatoolsci_getrecoverymodel"
            Get-Database -SqlInstance $server -Database $dbname | Remove-Database -Confirm:$false
            $server.Query("CREATE DATABASE $dbname; ALTER DATABASE $dbname SET RECOVERY BULK_LOGGED WITH NO_WAIT;")
        }
        AfterAll {
            Get-Database -SqlInstance $script:instance2 -Database $dbname | Remove-Database -Confirm:$false
        }

        It "gets the newly created database with the correct recovery model" {
            $results = Get-DbRecoveryModel -SqlInstance $script:instance2 -Database $dbname
            $results.RecoveryModel -eq 'BulkLogged' | Should Be $true
        }
        It "honors the RecoveryModel parameter filter" {
            $results = Get-DbRecoveryModel -SqlInstance $script:instance2 -RecoveryModel BulkLogged
            $results.Name -contains $dbname | Should Be $true
        }
    }
}