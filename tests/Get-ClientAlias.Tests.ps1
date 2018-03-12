$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    BeforeAll {
        $newalias = New-DbaClientAlias -ServerName sql2016 -Alias dbatoolscialias -Verbose:$false
    }
    AfterAll {
        $newalias | Remove-DbaClientAlias
    }

    Context "gets the alias" {
        $results = Get-DbaClientAlias
        It "returns accurate information" {
            $results.AliasName -contains 'dbatoolscialias' | Should Be $true
        }
    }
}