$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    BeforeAll {
        $dbname = "dbatoolsci_publishdacpac"
        $server = Connect-Instance -SqlInstance $script:instance1
        $null = $server.Query("Create Database [$dbname]")
        $db = Get-Database -SqlInstance $script:instance1 -Database $dbname
        $null = $db.Query("CREATE TABLE dbo.example (id int);
            INSERT dbo.example
            SELECT top 100 1
            FROM sys.objects")
        $publishprofile = New-PublishProfile -SqlInstance $script:instance1 -Database $dbname -Path C:\temp
        $dacpac = Export-Dacpac -SqlInstance $script:instance1 -Database $dbname
    }
    AfterAll {
        Remove-Database -SqlInstance $script:instance1, $script:instance2 -Database $dbname -Confirm:$false
        Remove-Item -Confirm:$false -Path $publishprofile.FileName -ErrorAction SilentlyContinue
    }
    It "shows that the update is complete" {
        $results = $dacpac | Publish-Dacpac -PublishXml $publishprofile.FileName -Database $dbname -SqlInstance $script:instance2
        $results.Result -match 'Update complete.' | Should Be $true
        if (($dacpac).Path) {
            Remove-Item -Confirm:$false -Path ($dacpac).Path -ErrorAction SilentlyContinue
        }
    }
}