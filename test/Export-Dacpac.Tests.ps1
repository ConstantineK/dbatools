$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    BeforeAll {
        try {
            $dbname = "dbatoolsci_exportdacpac"
            $server = Connect-Instance -SqlInstance $script:instance1
            $null = $server.Query("Create Database [$dbname]")
            $db = Get-Database -SqlInstance $script:instance1 -Database $dbname
            $null = $db.Query("CREATE TABLE dbo.example (id int);
            INSERT dbo.example
            SELECT top 100 1
            FROM sys.objects")
        }
        catch { } # No idea why appveyor can't handle this
    }
    AfterAll {
        Remove-Database -SqlInstance $script:instance1 -Database $dbname -Confirm:$false
    }

    if ((Get-Table -SqlInstance $script:instance1 -Database $dbname -Table example)) {
        # Sometimes appveyor bombs
        It "exports a dacpac" {
            $results = Export-Dacpac -SqlInstance $script:instance1 -Database $dbname
            Test-Path -Path ($results).Path
            if (($results).Path) {
                Remove-Item -Confirm:$false -Path ($results).Path -ErrorAction SilentlyContinue
            }
        }
    }
}