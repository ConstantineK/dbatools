$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    BeforeAll {
        Get-Database -SqlInstance $script:instance1, $script:instance2 | Where-Object Name -Match 'dbatoolsci' | Remove-Database -Confirm:$false
    }
    Context "Get some client protocols" {
        foreach ($instance in ($script:instance1, $script:instance2)) {
            $server = Connect-Instance -SqlInstance $instance
            $results = Get-DbQueryStoreOptions -SqlInstance $instance -WarningVariable warning  3>&1

            if ($server.VersionMajor -lt 13) {
                It "should warn" {
                    $warning | Should Not Be $null
                }
            }
            else {
                It "should return some valid results" {
                    $result = $results | Where-Object Database -eq msdb
                    $result.ActualState | Should Be 'Off'
                }

                It "should only get one database" {
                    $results = Get-DbQueryStoreOptions -SqlInstance $instance -Database model
                    $results.Count | Should Be 1
                    $results.Database | Should Be 'model'
                }

                It "should not get this one database" {
                    $results = Get-DbQueryStoreOptions -SqlInstance $instance -ExcludeDatabase model
                    $result = $results | Where-Object Database -eq model
                    $result.Count | Should Be 0
                }
            }
        }
    }
}