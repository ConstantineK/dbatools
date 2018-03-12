$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    $results = Disable-ForceNetworkEncryption $script:instance1 -EnableException

    It "returns false" {
        $results.ForceEncryption -eq $false
    }
}