$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

if (-not $env:appveyor) {
    Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
        $results = Get-ForceNetworkEncryption $script:instance1 -EnableException

        It "returns true or false" {
            $results.ForceEncryption -ne $null
        }
    }
}