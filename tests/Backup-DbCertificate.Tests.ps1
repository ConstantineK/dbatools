﻿$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Can create a database certificate" {
        BeforeAll {
            if (-not (Get-DatabaseMasterKey -SqlInstance $script:instance1 -Database tempdb)) {
                $masterkey = New-DatabaseMasterKey -SqlInstance $script:instance1 -Database tempdb -Password $(ConvertTo-SecureString -String "GoodPass1234!" -AsPlainText -Force) -Confirm:$false
            }
        }
        AfterAll {
            (Get-DbCertificate -SqlInstance $script:instance1 -Database tempdb) | Remove-DbCertificate -Confirm:$false
            (Get-DatabaseMasterKey -SqlInstance $script:instance1 -Database tempdb) | Remove-DatabaseMasterKey -Confirm:$false
        }

        $cert = New-DbCertificate -SqlInstance $script:instance1 -Database tempdb
        $results = Backup-DbCertificate -SqlInstance $script:instance1 -Certificate $cert.Name -Database tempdb
        $null = Remove-Item -Path $results.Path -ErrorAction SilentlyContinue -Confirm:$false

        It "backs up the db cert" {
            $results.Certificate -match $certificateName1
            $results.Status -match "Success"
        }
    }
}