$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {

    Context "executes and returns the accurate info" {
        $results = Get-AgentJob -SqlInstance $script:instance2 -Job 'DatabaseBackup - SYSTEM_DATABASES - FULL' | Start-AgentJob
        It -Skip "returns a CurrentRunStatus of not Idle" {
            $null = Get-AgentJob -SqlInstance $script:instance2 -Job 'DatabaseBackup - SYSTEM_DATABASES - FULL' | Stop-AgentJob
            $results.CurrentRunStatus -ne 'Idle' | Should Be $true
        }
    }
}