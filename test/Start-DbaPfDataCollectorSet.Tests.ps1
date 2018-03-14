$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    BeforeAll {
        $script:set = Get-PfDataCollectorSet | Select-Object -First 1
        $script:set | Stop-PfDataCollectorSet -WarningAction SilentlyContinue
        Start-Sleep 2
    }
    AfterAll {
        $script:set | Stop-PfDataCollectorSet -WarningAction SilentlyContinue
    }
    Context "Verifying command works" {
        It "returns a result with the right computername and name is not null" {
            $results = $script:set | Select-Object -First 1 | Start-PfDataCollectorSet -WarningAction SilentlyContinue -WarningVariable warn
            if (-not $warn) {
                $results.ComputerName | Should Be $env:COMPUTERNAME
                $results.Name | Should Not Be $null
            }
        }
    }
}