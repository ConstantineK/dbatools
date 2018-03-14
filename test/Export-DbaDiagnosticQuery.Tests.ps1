$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    AfterAll {
        (Get-ChildItem "$env:temp\dbatoolsci") | Remove-Item
    }
    Context "Verifying output" {
        It "exports results to one file and creates directory if required" {
            $results = Invoke-DiagnosticQuery -SqlInstance $script:instance2 -QueryName 'Memory Clerk Usage' | Export-DiagnosticQuery -Path "$env:temp\dbatoolsci"
            (Get-ChildItem "$env:temp\dbatoolsci").Count | Should Be 1
        }
    }
}