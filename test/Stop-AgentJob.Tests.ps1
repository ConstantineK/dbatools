$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "executes and returns the accurate info" {
        It -Skip "returns a CurrentRunStatus of Idle" {
            $agent = Get-AgentJob -SqlInstance $script:instance2 -Job 'DatabaseBackup - SYSTEM_DATABASES - FULL' | Start-AgentJob | Stop-AgentJob
            $results.CurrentRunStatus -eq 'Idle' | Should Be $true
        }
    }
}