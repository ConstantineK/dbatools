﻿$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

$outputFile = "$env:temp\dbatoolsci_user.sql"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    BeforeAll {
        try {
            $dbname = "dbatoolsci_exportdbauser"
            $login = "dbatoolsci_exportdbauser_login"
            $user = "dbatoolsci_exportdbauser_user"
            $server = Connect-Instance -SqlInstance $script:instance1
            $null = $server.Query("CREATE DATABASE [$dbname]")

            $securePassword = $(ConvertTo-SecureString -String "GoodPass1234!" -AsPlainText -Force)
            $null = New-Login -SqlInstance $script:instance1 -Login $login -Password $securePassword

            $db = Get-Database -SqlInstance $script:instance1 -Database $dbname
            $null = $db.Query("CREATE USER [$user] FOR LOGIN [$login]")
        }
        catch { } # No idea why appveyor can't handle this
    }
    AfterAll {
        Remove-Database -SqlInstance $script:instance1 -Database $dbname -Confirm:$false
        Remove-Login -SqlInstance $script:instance1 -Login $login -Confirm:$false
        (Get-ChildItem $outputFile) | Remove-Item -ErrorAction SilentlyContinue
    }

    Context "Check if output file was created" {
        if (Get-DatabaseUser -SqlInstance $script:instance1 -Database $dbname | Where-Object Name -eq $user) {
            $results = Export-User -SqlInstance $script:instance1 -Database $dbname -User $user -FilePath $outputFile
            It "Exports results to one sql file" {
                (Get-ChildItem $outputFile).Count | Should Be 1
            }
            It "Exported file is bigger than 0" {
                (Get-ChildItem $outputFile).Length | Should BeGreaterThan 0
            }
        }
    }
}