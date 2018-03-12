$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    Context "Returns output for single database" {
        BeforeAll {
            $server = Connect-Instance -SqlInstance $script:instance2
            $random = Get-Random
            $db = "dbatoolsci_measurethruput$random"
            $server.Query("CREATE DATABASE $db")
            $null = Get-Database -SqlInstance $server -Database $db | Backup-Database
        }
        AfterAll {
            $null = Get-Database -SqlInstance $server -Database $db | Remove-Database -Confirm:$false
        }

        $results = Measure-BackupThroughput -SqlInstance $server -Database $db
        It "Should return just one backup" {
            $results.Database.Count -eq 1 | Should Be $true
        }
    }
}
