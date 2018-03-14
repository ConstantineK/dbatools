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
        It "returns a file system object" {
            $results = Get-PfDataCollectorSet -CollectorSet 'Long Running Queries' | Export-PfDataCollectorSetTemplate
            $results.BaseName | Should Be 'Long Running Queries'
        }
        It "returns a file system object" {
            $results = Export-PfDataCollectorSetTemplate -CollectorSet 'Long Running Queries'
            $results.BaseName | Should Be 'Long Running Queries'
        }
    }
}