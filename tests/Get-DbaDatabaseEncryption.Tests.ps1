$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Test Retriving Certificate" {
        BeforeAll {
            $random = Get-Random
            $cert = "dbatoolsci_getcert$random"
            $password = ConvertTo-SecureString -String Get-Random -AsPlainText -Force
            New-DbCertificate -SqlInstance $script:instance1 -Name $cert -password $password
        }
        AfterAll {
            Get-DbCertificate -SqlInstance $script:instance1 -Certificate $cert | Remove-DbCertificate -confirm:$false
        }
        $results = Get-DatabaseEncryption -SqlInstance $script:instance1
        It "Should find a certificate named $cert" {
            ($results.Name -match 'dbatoolsci').Count -gt 0 | Should Be $true
        }
    }
}