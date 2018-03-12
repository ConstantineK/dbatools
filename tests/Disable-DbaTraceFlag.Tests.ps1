$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    Context "Verifying TraceFlag output" {
        BeforeAll {
            $server = Connect-Instance -SqlInstance $script:instance1
            $startingtfs = Get-TraceFlag -SqlInstance $server
            $safetraceflag = 3226

            if ($startingtfs.TraceFlag -notcontains $safetraceflag) {
                $null = $server.Query("DBCC TRACEON($safetraceflag,-1)")
            }

        }
        AfterAll {
            if ($startingtfs.TraceFlag -contains $safetraceflag) {
                $server.Query("DBCC TRACEON($safetraceflag,-1)  WITH NO_INFOMSGS")
            }
        }

        $results = Disable-TraceFlag -SqlInstance $server -TraceFlag $safetraceflag

        It "Return $safetraceflag as disabled" {
            $results.TraceFlag -contains $safetraceflag | Should Be $true
        }
    }
}