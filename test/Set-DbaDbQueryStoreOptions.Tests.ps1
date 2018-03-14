$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    BeforeAll {
        $null = Get-Database -SqlInstance $script:instance1, $script:instance2 | Where-Object Name -Match 'dbatoolsci' | Remove-Database -Confirm:$false
    }
    Context "Set some options" {
        foreach ($instance in ($script:instance1, $script:instance2)) {
            $server = Connect-Instance -SqlInstance $instance
            $results = Get-DbQueryStoreOptions -SqlInstance $instance -WarningVariable warning  3>&1

            if ($server.VersionMajor -lt 13) {
                It "should warn" {
                    $warning | Should Not Be $null
                }
            }
            else {
                It "should return a default" {
                    $result = $results | Where-Object Database -eq msdb
                    $result.MaxStorageSizeInMB | Should BeGreaterThan 1
                }

                $newnumber = $oldnumber + 1
                $null = Set-DbQueryStoreOptions -SqlInstance $instance -Database msdb -State Off

                It "should warn that state is off" {
                    $results = Set-DbQueryStoreOptions -SqlInstance $instance -Database msdb -FlushInterval $newnumber -WarningVariable warning  3>&1
                    $warning | Should Not Be $null
                }

                It "should change the specified param to the new value" {
                    $results = Set-DbQueryStoreOptions -SqlInstance $instance -Database msdb -FlushInterval $newnumber -State ReadWrite
                    $results.DataFlushIntervalInSeconds | Should Be $newnumber
                }
            }
        }
    }
}