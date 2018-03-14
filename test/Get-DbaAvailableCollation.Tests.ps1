$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Available Collations" {
        $results = Get-AvailableCollation -SqlInstance $script:instance2
        It "finds a collation that matches Slovenian" {
            ($results.Name -match 'Slovenian').Count -gt 10 | Should Be $true
        }
    }
}