$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "command can run" {
        It "should be able to run - not much to test here" {
            Test-DbCompression -SqlInstance $script:instance2 -Database tempdb | Should Be $null
        }
    }
}