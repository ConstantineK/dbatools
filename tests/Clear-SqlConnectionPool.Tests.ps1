$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    It "doesn't throw" {
        { Clear-SqlConnectionPool }  | Should Not Throw
    }
}