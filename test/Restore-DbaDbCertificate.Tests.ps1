$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Can create a database certificate" {
        BeforeAll {
            $masterkey = New-DatabaseMasterKey -SqlInstance $script:instance1 -Database tempdb -Password $(ConvertTo-SecureString -String "GoodPass1234!" -AsPlainText -Force) -Confirm:$false
        }
        AfterAll {
            $null = $masterkey | Remove-DatabaseMasterKey -Confirm:$false
        }

        $password = ConvertTo-SecureString -AsPlainText "GoodPass1234!!" -force
        $cert = New-DbCertificate -SqlInstance $script:instance1 -Database tempdb
        $backup = Backup-DbCertificate -SqlInstance $script:instance1 -Database tempdb -EncryptionPassword $password
        $null = Remove-DbCertificate -SqlInstance $script:instance1 -Certificate $cert.Name -Database tempdb -Confirm:$false
        $results = Restore-DbCertificate -SqlInstance $script:instance1 -Path $backup.ExportPath -Password $password -Database tempdb

        It "restores the db cert" {
            $results.Parent.Name -eq 'tempdb'
            $null -ne $results.Name
            $results.PrivateKeyEncryptionType -eq "Password"
        }

        $results | Remove-DbCertificate -Confirm:$false
    }
}