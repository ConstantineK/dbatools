$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    BeforeAll {
        $inst1CurrentSqlMax = (Get-MaxMemory -SqlInstance $script:instance1).SqlMaxMB
        $inst2CurrentSqlMax = (Get-MaxMemory -SqlInstance $script:instance2).SqlMaxMB
    }
    AfterAll {
       $null = Set-MaxMemory -SqlInstance $script:instance1 -MaxMB $inst1CurrentSqlMax
       $null = Set-MaxMemory -SqlInstance $script:instance2 -MaxMB $inst2CurrentSqlMax
    }
    Context "Connects to multiple instances" {
        $results = Set-MaxMemory -SqlInstance $script:instance1, $script:instance2 -MaxMB 1024
        foreach ($result in $results) {
            It 'Returns 1024 MB for each instance' {
                $result.CurrentMaxValue | Should Be 1024
            }
        }
    }
}

Describe "$CommandName Unit Tests" -Tag 'UnitTests' {
    InModuleScope sqlshell{
        Context 'Validate input arguments' {
            It 'SqlInstance parameter host cannot be found' {
                Set-MaxMemory -SqlInstance 'ABC' 3> $null | Should be $null
            }
        }
    }
}
