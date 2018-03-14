$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    Context "Verifying output" {
        It "runs a specific query" {
            $results = Invoke-DiagnosticQuery -SqlInstance $script:instance2 -QueryName 'Memory Clerk Usage' *>&1
            $results.Name.Count | Should Be 1
        }
        It "works with DatabaseSpecific" {
            $results = Invoke-DiagnosticQuery -SqlInstance $script:instance2 -DatabaseSpecific *>&1
            $results.Name.Count -gt 10 | Should Be $true
        }
    }
}