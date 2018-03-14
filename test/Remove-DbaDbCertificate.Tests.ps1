$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Can remove a database certificate" {
        BeforeAll {
            if (-not (Get-DatabaseMasterKey -SqlInstance $script:instance1 -Database master)) {
                $masterkey = New-DatabaseMasterKey -SqlInstance $script:instance1 -Database master -Password $(ConvertTo-SecureString -String "GoodPass1234!" -AsPlainText -Force) -Confirm:$false
            }
        }
        AfterAll {
            if ($masterKey) { $masterkey | Remove-DatabasemasterKey -Confirm:$false }
        }

        $results = New-DbCertificate -SqlInstance $script:instance1 | Remove-DbCertificate -Confirm:$false

        It "Successfully removes database certificate in master" {
            "$($results.Status)" -match 'Success' | Should Be $true
        }
    }
}