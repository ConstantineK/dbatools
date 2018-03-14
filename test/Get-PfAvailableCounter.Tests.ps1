$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    BeforeEach {
        $null = Get-PfDataCollectorSetTemplate -Template 'Long Running Queries' | Import-PfDataCollectorSetTemplate
    }
    AfterAll {
        $null = Get-PfDataCollectorSet -CollectorSet 'Long Running Queries' | Remove-PfDataCollectorSet -Confirm:$false
    }
    Context "Verifying command returns all the required results" {
        It "returns the correct values" {
            $results = Get-PfAvailableCounter
            $results.Count -gt 1000 | Should Be $true
        }
        It "returns are pipable into Add-PfDataCollectorCounter" {
            $results = Get-PfAvailableCounter -Pattern *sql* | Select-Object -First 3 | Add-PfDataCollectorCounter -CollectorSet 'Long Running Queries' -Collector DataCollector01 -WarningAction SilentlyContinue
            foreach ($result in $results) {
                $result.Name -match "sql" | Should Be $true
            }
        }
    }
}