$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Recovery model is correctly set" {
        BeforeAll {
            $server = Connect-Instance -SqlInstance $script:instance2
            $dbname = "dbatoolsci_recoverymodel"
            Get-Database -SqlInstance $server -Database $dbname | Remove-Database -Confirm:$false
            $server.Query("CREATE DATABASE $dbname")
        }
        AfterAll {
            Get-Database -SqlInstance $script:instance2 -Database $dbname | Remove-Database -Confirm:$false
        }

        $results = Set-DbRecoveryModel -SqlInstance $script:instance2 -Database $dbname -RecoveryModel BulkLogged -Confirm:$false

        It "sets the proper recovery model" {
            $results.RecoveryModel -eq "BulkLogged" | Should Be $true
        }

        It "supports the pipeline" {
            $results = Get-Database -SqlInstance $script:instance2 -Database $dbname | Set-DbRecoveryModel -RecoveryModel Simple -Confirm:$false
            $results.RecoveryModel -eq "Simple" | Should Be $true
        }

        It "requires Database, ExcludeDatabase or AllDatabases" {
            $results = Set-DbRecoveryModel -SqlInstance $script:instance2 -RecoveryModel Simple -WarningAction SilentlyContinue -WarningVariable warn -Confirm:$false
            $warn -match "AllDatabases" | Should Be $true
        }

    }
}
