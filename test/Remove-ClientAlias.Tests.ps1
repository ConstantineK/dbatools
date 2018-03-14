﻿$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    BeforeAll {
        $null = New-ClientAlias -ServerName sql2016 -Alias dbatoolscialias-new -Verbose:$false
    }
    Context "adds the alias" {
        $results = Remove-ClientAlias -Alias dbatoolscialias-new -Verbose:$false
        It "alias is not included in results" {
            $results.AliasName -notcontains 'dbatoolscialias-new' | Should Be $true
        }
    }
}