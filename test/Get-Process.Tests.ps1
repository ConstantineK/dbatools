$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Testing Get-Process results" {
        $results = Get-Process -SqlInstance $script:instance1

        It "matches self as a login at least once" {
            $matching = $results | Where-Object Login -match $env:username
            $matching.Length | Should BeGreaterThan 0
        }

        $results = Get-Process -SqlInstance $script:instance1 -Program 'sqlshellPowerShell module - dbatools.io'

        foreach ($result in $results) {
            It "returns only sqlshellprocesses" {
                $result.Program -eq 'sqlshellPowerShell module - dbatools.io' | Should Be $true
            }
        }

        $results = Get-Process -SqlInstance $script:instance1 -Database master

        foreach ($result in $results) {
            It "returns only processes from master database" {
                $result.Database -eq 'master' | Should Be $true
            }
        }
    }
}
