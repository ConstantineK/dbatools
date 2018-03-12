$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Testing if schema changes are discovered" {
        BeforeAll {
            $db = Get-Database -SqlInstance $script:instance1 -Database tempdb
            $db.Query("CREATE TABLE dbatoolsci_schemachange (id int identity)")
            $db.Query("EXEC sp_rename 'dbatoolsci_schemachange', 'dbatoolsci_schemachange1'")
        }
        AfterAll {
            $db.Query("DROP TABLE dbo.dbatoolsci_schemachange1")
        }

        $results = Get-SchemaChangeHistory -SqlInstance $script:instance1 -Database tempdb

        It "notices dbatoolsci_schemachange changed" {
            $results.Object -match 'dbatoolsci_schemachange' | Should Be $true
        }
    }
}
