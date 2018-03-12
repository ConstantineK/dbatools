$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "returns the proper transport" {
        $results = Test-ConnectionAuthScheme -SqlInstance $script:instance1
        It "returns ntlm auth scheme" {
            $results.AuthScheme | Should Be 'ntlm'
        }
    }
}