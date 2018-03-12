$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    BeforeEach {
        $null = Get-PfDataCollectorSetTemplate -Template 'Long Running Queries' | Import-PfDataCollectorSetTemplate
    }
    Context "Verifying command return the proper results" {

        It "removes the data collector set" {
            $results = Get-PfDataCollectorSet -CollectorSet 'Long Running Queries' | Remove-PfDataCollectorSet -Confirm:$false
            $results.Name | Should Be 'Long Running Queries'
            $results.Status | Should Be 'Removed'
        }

        It "returns a result" {
            $results = Get-PfDataCollectorSet -CollectorSet 'Long Running Queries'
            $results.Name | Should Be 'Long Running Queries'
        }

        It "returns no results" {
            $null = Remove-PfDataCollectorSet -CollectorSet 'Long Running Queries' -Confirm:$false
            $results = Get-PfDataCollectorSet -CollectorSet 'Long Running Queries'
            $results.Name | Should Be $null
        }
    }
}