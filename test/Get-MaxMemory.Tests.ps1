$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Connects to multiple instances" {
        It 'Returns multiple objects' {
            $results = Get-MaxMemory -SqlInstance $script:instance1, $script:instance2
            $results.Count | Should BeGreaterThan 1 # and ultimately not throw an exception
        }
        It 'Returns the right amount of MB' {
            $null = Set-MaxMemory -SqlInstance $script:instance1, $script:instance2 -MaxMB 1024
            $results = Get-MaxMemory -SqlInstance $script:instance1
            $results.SqlMaxMB | Should Be 1024
        }
    }
}

Describe "$commandname Unit Test" -Tags Unittest {
    InModuleScope sqlshell{
        Context 'Validate input arguments' {
            It 'SqlInstance parameter is empty' {
                Mock Connect-SqlInstance { throw System.Data.SqlClient.SqlException }
                { Get-MaxMemory -SqlInstance '' -WarningAction Stop 3> $null } | Should Throw
            }

            It 'SqlInstance parameter host cannot be found' {
                Mock Connect-SqlInstance { throw System.Data.SqlClient.SqlException }
                { Get-MaxMemory -SqlInstance 'ABC' -WarningAction Stop 3> $null } | Should Throw
            }
        }

        Context 'Validate functionality ' {
            It 'Server SqlInstance reported correctly' {
                Mock Connect-SqlInstance {
                    return @{
                        DomainInstanceName = 'ABC'
                    }
                }

                (Get-MaxMemory -SqlInstance 'ABC').SqlInstance | Should be 'ABC'
            }

            It 'Server under-report by 1MB the memory installed on the host' {
                Mock Connect-SqlInstance {
                    return @{
                        PhysicalMemory = 1023
                    }
                }

                (Get-MaxMemory -SqlInstance 'ABC').TotalMB | Should be 1024
            }

            It 'Server reports correctly the memory installed on the host' {
                Mock Connect-SqlInstance {
                    return @{
                        PhysicalMemory = 1024
                    }
                }

                (Get-MaxMemory -SqlInstance 'ABC').TotalMB | Should be 1024
            }

            It 'Memory allocated to SQL Server instance reported' {
                Mock Connect-SqlInstance {
                    return @{
                        Configuration = @{
                            MaxServerMemory = @{
                                ConfigValue = 2147483647
                            }
                        }
                    }
                }

                (Get-MaxMemory -SqlInstance 'ABC').SqlMaxMB | Should be 2147483647
            }
        }
    }
}
