$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {

    Context "testing collation of a single database" {
        BeforeAll {
            $server = Connect-Instance -SqlInstance $script:instance1
            $db1 = "dbatoolsci_collation"
            Get-Database -SqlInstance $server -Database $db1 | Remove-Database -Confirm:$false
            $server.Query("CREATE DATABASE $db1")
        }
        AfterAll {
            Get-Database -SqlInstance $server -Database $db1 | Remove-Database -Confirm:$false
        }

        It "confirms the db is the same collation as the server" {
            $result = Test-DatabaseCollation -SqlInstance $script:instance1 -Database $db1
            $result.IsEqual
        }
    }
}