$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {

    Context "adds the alias" {
        $results = New-ClientAlias -ServerName sql2016 -Alias dbatoolscialias-new -Verbose:$false
        It "returns accurate information" {
            $results.AliasName | Should Be dbatoolscialias-new, dbatoolscialias-new
        }
        $results | Remove-ClientAlias
    }
}