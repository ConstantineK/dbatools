$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    BeforeEach {
        $null = Get-PfDataCollectorSetTemplate -Template 'Long Running Queries' | Import-PfDataCollectorSetTemplate |
        Get-PfDataCollector | Get-PfDataCollectorCounter -Counter '\LogicalDisk(*)\Avg. Disk Queue Length' | Remove-PfDataCollectorCounter -Confirm:$false
    }
    AfterAll {
        $null = Get-PfDataCollectorSet -CollectorSet 'Long Running Queries' | Remove-PfDataCollectorSet -Confirm:$false
    }
    Context "Verifying command returns all the required results" {
        It "returns the correct values" {
            $results = Get-PfDataCollectorSet -CollectorSet 'Long Running Queries' | Get-PfDataCollector | Add-PfDataCollectorCounter -Counter '\LogicalDisk(*)\Avg. Disk Queue Length'
            $results.DataCollectorSet | Should Be 'Long Running Queries'
            $results.Name | Should Be '\LogicalDisk(*)\Avg. Disk Queue Length'
        }
    }
}