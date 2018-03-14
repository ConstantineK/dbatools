$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    BeforeAll {
        $singledb = "dbatoolsci_singledb"
        $dbs = "dbatoolsci_lildb", "dbatoolsci_testMaxDop", $singledb
        $null = Get-Database -SqlInstance $script:instance2 -Database $dbs | Remove-Database -Confirm:$false
        $server = Connect-Instance -SqlInstance $script:instance2
        $server2 = Connect-Instance -SqlInstance $script:instance1

        foreach ($db in $dbs) {
            $server.Query("CREATE DATABASE $db")
            $server2.Query("CREATE DATABASE $db")
        }

    }
    AfterAll {
        # these for sure
        Get-Database -SqlInstance $script:instance1 -Database $dbs | Remove-Database -Confirm:$false
        Get-Database -SqlInstance $script:instance2 -Database $dbs | Remove-Database -Confirm:$false
    }

    Context "Apply to multiple instances" {
        $results = Set-MaxDop -SqlInstance $script:instance1, $script:instance2 -MaxDop 2
        foreach ($result in $results) {
            It 'Returns MaxDop 2 for each instance' {
                $result.CurrentInstanceMaxDop | Should Be 2
            }
        }
    }

    Context "Connects to 2016+ instance and apply configuration to single database" {
        $results = Set-MaxDop -SqlInstance $script:instance2 -MaxDop 4 -Database $singledb
        foreach ($result in $results) {
            It 'Returns 4 for each database' {
                $result.DatabaseMaxDop | Should Be 4
            }
        }
    }

    Context "Connects to 2016+ instance and apply configuration to multiple databases" {
        $results = Set-MaxDop -SqlInstance $script:instance2 -MaxDop 8 -Database $dbs
        foreach ($result in $results) {
            It 'Returns 8 for each database' {
                $result.DatabaseMaxDop | Should Be 8
            }
        }
    }
}

Describe "$commandname Unit Tests" -Tags "UnitTests", Set-MaxDop {
    Context "Input validation" {
        BeforeAll {
            Mock Stop-Function { } -ModuleName dbatools
        }
        It "Should Call Stop-Function. -Database, -AllDatabases and -ExcludeDatabase are mutually exclusive." {
            Set-MaxDop -SqlInstance $script:instance1 -MaxDop 12 -Database $singledb -AllDatabases -ExcludeDatabase "master" | Should Be
        }
        It "Validates that Stop Function Mock has been called" {
            $assertMockParams = @{
                'CommandName' = 'Stop-Function'
                'Times'       = 1
                'Exactly'     = $true
                'Module'      = 'dbatools'
            }
            Assert-MockCalled @assertMockParams
        }
    }
}