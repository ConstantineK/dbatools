$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Command executes properly and returns proper info" {
        $results = Clear-WaitStatistics -SqlInstance $script:instance1 -Confirm:$false

        It "returns success" {
            $results.Status -eq 'Success' | Should Be $true
        }
    }
}