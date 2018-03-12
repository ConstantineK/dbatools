﻿$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    It "supports pipable instances" {
        $results = $script:instance1, $script:instance2 | Invoke-SqlQuery -Database tempdb -Query "Select 'hello' as TestColumn"
        foreach ($result in $results) {
            $result.TestColumn -eq 'hello'
        }
    }
}