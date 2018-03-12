$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Unit Tests" -Tag 'UnitTests' {
    BeforeAll {
        $server = Connect-Instance -SqlInstance $script:instance2
        $random = Get-Random
        $db = "dbatoolsci_writedbadaatable$random"
        $server.Query("CREATE DATABASE $db")
    }
    AfterAll {
        $null = Get-Database -SqlInstance $server -Database $db | Remove-Database -Confirm:$false
    }

    # calling random function to throw data into a table
    It "defaults to dbo if no schema is specified" {
        $results = Get-ChildItem | ConvertTo-DataTable
        $results | Write-DataTable -SqlInstance $script:instance2 -Database $db -Table 'childitem' -AutoCreateTable

        ($server.Databases[$db].Tables | Where-Object { $_.Schema -eq 'dbo' -and $_.Name -eq 'childitem' }).Count | Should Be 1
    }
}