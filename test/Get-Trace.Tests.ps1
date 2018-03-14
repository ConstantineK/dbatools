$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    BeforeAll {
        $traceconfig = Get-SpConfigure -SqlInstance $script:instance2 -ConfigName DefaultTraceEnabled

        if ($traceconfig.RunningValue -eq $false) {
            $server = Connect-Instance -SqlInstance $script:instance2
            $server.Query("EXEC sp_configure 'show advanced options', 1;")
            $server.Query("RECONFIGURE WITH OVERRIDE")
            $server.Query("EXEC sp_configure 'default trace enabled', 1;")
            $server.Query("RECONFIGURE WITH OVERRIDE")
            $server.Query("EXEC sp_configure 'show advanced options', 0;")
            $server.Query("RECONFIGURE WITH OVERRIDE")
        }
    }

    AfterAll {
        if ($traceconfig.RunningValue -eq $false) {
            $server.Query("EXEC sp_configure 'show advanced options', 1;")
            $server.Query("RECONFIGURE WITH OVERRIDE")
            $server.Query("EXEC sp_configure 'default trace enabled', 0;")
            $server.Query("RECONFIGURE WITH OVERRIDE")
            $server.Query("EXEC sp_configure 'show advanced options', 0;")
            $server.Query("RECONFIGURE WITH OVERRIDE")
            #$null = Set-SpConfigure -SqlInstance $script:instance2 -ConfigName DefaultTraceEnabled -Value $false
        }
    }
    Context "Test Check Default Trace" {
        $results = Get-Trace -SqlInstance $script:instance2
        It "Should find at least one trace file" {
            $results.Id.Count -gt 0 | Should Be $true
        }
    }
}