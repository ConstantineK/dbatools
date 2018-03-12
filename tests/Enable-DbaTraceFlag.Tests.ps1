$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    Context "Verifying TraceFlag output" {
        BeforeAll {
            $server = Connect-Instance -SqlInstance $script:instance2
            $startingtfs = Get-TraceFlag -SqlInstance $script:instance2
            $safetraceflag = 3226

            if ($startingtfs.TraceFlag -contains $safetraceflag) {
                $server.Query("DBCC TRACEOFF($safetraceflag,-1)")
            }
        }
        AfterAll {
            if ($startingtfs.TraceFlag -notcontains $safetraceflag) {
                $server.Query("DBCC TRACEOFF($safetraceflag,-1)")
            }
        }

        $results = Enable-TraceFlag -SqlInstance $server -TraceFlag $safetraceflag

        It "Return $safetraceflag as enabled" {
            $results.TraceFlag -contains $safetraceflag | Should Be $true
        }
    }
}
