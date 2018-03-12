$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Command returns proper info" {
        $results = Get-UserLevelPermission -SqlInstance $script:instance1 -Database tempdb

        It "returns results" {
            $results.Count -gt 0 | Should Be $true
        }

        foreach ($result in $results) {
            It "returns only tempdb or server results" {
                $result.Object -in 'tempdb', 'SERVER' | Should Be $true
            }
        }
    }
}