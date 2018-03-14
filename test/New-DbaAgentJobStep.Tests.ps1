$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    Context "New Agent Job Step is added properly" {

        # Create job to add step to
        $job = New-AgentJob -SqlInstance $script:instance2 -Job "Job One" -Description "Just another job"

        It "Should have the right name and description" {
            $results = New-AgentJobStep -SqlInstance $script:instance2 -Job $job -StepName "Step One"
            $results.Name | Should Be "Step One"
        }

        It "Should actually for sure exist" {
            $newresults = Get-AgentJob -SqlInstance $script:instance2 -Job "Job One"
            $newresults.JobSteps.Name | Should Be "Step One"
        }

        It "Should not write over existing job steps" {
            New-AgentJobStep -SqlInstance $script:instance2 -Job "Job One" -StepName "Step One" -WarningAction SilentlyContinue -WarningVariable warn
            $warn -match "already exists" | Should Be $true
        }

        # Cleanup and ignore all output
        Remove-AgentJob -SqlInstance $script:instance2 -Job "Job One" *> $null
    }
}
