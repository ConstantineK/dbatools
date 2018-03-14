$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

# This is quite light of a test but setting up a proxy requires a lot of setup and I don't have time today
Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "does not try to add without" {
        $results = New-AgentProxy -SqlInstance $script:instance2 -Name STIG -Credential 'dbatoolsci_proxytest' -WarningAction SilentlyContinue -WarningVariable warn
        It "does not try to add the proxy without a valid credential" {
            $warn -match 'does not exist' | Should Be $true
        }
    }
}