﻿$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Testing if suspect pages are present" {
        BeforeAll {
            $dbname = "dbatoolsci_GetSuspectPage"
            $Server = Connect-Instance -SqlInstance $script:instance2
            $null = $Server.Query("Create Database [$dbname]")
            $db = Get-Database -SqlInstance $Server -Database $dbname
        }
        AfterAll {
            Remove-Database -SqlInstance $Server -Database $dbname -Confirm:$false
        }

        $null = $db.Query("
        CREATE TABLE dbo.[Example] (id int);
        INSERT dbo.[Example]
        SELECT top 1000 1
        FROM sys.objects")

        # make darn sure suspect pages show up, run twice
        try {
            $null = Invoke-DatabaseCorruption -SqlInstance $script:instance2 -Database $dbname -Confirm:$false
            $null = $db.Query("select top 100 from example")
            $null = $server.Query("ALTER DATABASE $dbname SET PAGE_VERIFY CHECKSUM  WITH NO_WAIT")
            $null = Start-DbccCheck -Server $Server -dbname $dbname -WarningAction SilentlyContinue
        }
        catch {} # should fail

        try {
            $null = Invoke-DatabaseCorruption -SqlInstance $script:instance2 -Database $dbname -Confirm:$false
            $null = $db.Query("select top 100 from example")
            $null = $server.Query("ALTER DATABASE $dbname SET PAGE_VERIFY CHECKSUM  WITH NO_WAIT")
            $null = Start-DbccCheck -Server $Server -dbname $dbname -WarningAction SilentlyContinue
        }
        catch { } # should fail

        $results = Get-SuspectPage -SqlInstance $server
        It "function should find at least one record in suspect_pages table" {
            $results.Database -contains $dbname | Should Be $true
        }
    }
}
