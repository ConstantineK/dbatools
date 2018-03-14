$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Testing if command works" {

        $results = Test-Connection -SqlInstance $script:instance1
        $whoami = whoami
        It "returns the correct port" {
            $results.TcpPort -eq 1433 | Should Be $true
        }

        It "returns the correct authtype" {
            $results.AuthType -eq 'Windows Authentication' | Should Be $true
        }

        It "returns the correct user" {
            $results.ConnectingAsUser -eq $whoami | Should Be $true
        }
    }
}