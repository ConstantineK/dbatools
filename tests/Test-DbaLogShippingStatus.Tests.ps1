$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    It "warns if SQL instance edition is not supported" {
        $results = Test-LogShippingStatus -SqlInstance $script:instance1 -WarningAction SilentlyContinue -WarningVariable editionwarn
        $editionwarn -match "Express" | Should Be $true
    }

    It "warns if no log shipping found" {
        $results = Test-LogShippingStatus -SqlInstance $script:instance2 -Database 'master' -WarningAction SilentlyContinue -WarningVariable doesntexist
        $doesntexist -match "No information available" | Should Be $true
    }
}
