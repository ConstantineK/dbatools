$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    Context "New Agent JOb is added properly" {

        It "Should have the right name and description" {
            $results = New-AgentJob -SqlInstance $script:instance2 -Job "Job One" -Description "Just another job"
            $results.Name | Should Be "Job One"
            $results.Description | Should Be "Just another job"
        }

        It "Should actually for sure exist" {
            $newresults = Get-AgentJob -SqlInstance $script:instance2 -Job "Job One"
            $newresults.Name | Should Be "Job One"
            $newresults.Description | Should Be "Just another job"
        }

        It "Should not write over existing jobs" {
            $results = New-AgentJob -SqlInstance $script:instance2 -Job "Job One" -Description "Just another job" -WarningAction SilentlyContinue -WarningVariable warn
            $warn -match "already exists" | Should Be $true
        }

        # Cleanup and ignore all output
        Remove-AgentJob -SqlInstance $script:instance2 -Job "Job One" *> $null
    }
}