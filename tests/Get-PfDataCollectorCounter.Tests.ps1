﻿$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    Context "Verifying command works" {
        It "returns a result with the right computername and name is not null" {
            $results = Get-PfDataCollectorCounter | Select-Object -First 1
            $results.ComputerName | Should Be $env:COMPUTERNAME
            $results.Name | Should Not Be $null
        }
    }
}