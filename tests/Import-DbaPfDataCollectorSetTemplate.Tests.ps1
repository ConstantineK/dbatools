$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    BeforeEach {
        $null = Get-PfDataCollectorSet -CollectorSet 'Long Running Queries' | Remove-PfDataCollectorSet -Confirm:$false
    }
    AfterAll {
        $null = Get-PfDataCollectorSet -CollectorSet 'Long Running Queries' | Remove-PfDataCollectorSet -Confirm:$false
    }
    Context "Verifying command returns all the required results with pipe" {
        It "returns only one (and the proper) template" {
            $results = Get-PfDataCollectorSetTemplate -Template 'Long Running Queries' | Import-PfDataCollectorSetTemplate
            $results.Name | Should Be 'Long Running Queries'
            $results.ComputerName | Should Be $env:COMPUTERNAME
        }
        It "returns only one (and the proper) template without pipe" {
            $results = Import-PfDataCollectorSetTemplate -Template 'Long Running Queries'
            $results.Name | Should Be 'Long Running Queries'
            $results.ComputerName | Should Be $env:COMPUTERNAME
        }
    }
}