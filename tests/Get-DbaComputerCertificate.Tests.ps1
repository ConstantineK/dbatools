$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Can get a certificate" {
        BeforeAll {
            $null = Add-ComputerCertificate -Path $script:appveyorlabrepo\certificates\localhost.crt -Confirm:$false
            $thumbprint = "29C469578D6C6211076A09CEE5C5797EEA0C2713"
        }
        AfterAll {
            Remove-ComputerCertificate -Thumbprint $thumbprint -Confirm:$false
        }

        $cert = Get-ComputerCertificate -Thumbprint $thumbprint

        It "returns a single certificate with a specific thumbprint" {
            $cert.Thumbprint | Should Be $thumbprint
        }

        $cert = Get-ComputerCertificate

        It "returns all certificates and at least one has the specified thumbprint" {
            "$($cert.Thumbprint)" -match $thumbprint | Should Be $true
        }
        It "returns all certificates and at least one has the specified EnhancedKeyUsageList" {
            "$($cert.EnhancedKeyUsageList)" -match '1\.3\.6\.1\.5\.5\.7\.3\.1' | Should Be $true
        }
    }
}