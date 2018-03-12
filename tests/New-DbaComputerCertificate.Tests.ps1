if (-not $env:appveyor) {
    $CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

    . "$PSScriptRoot\constants.ps1"

    Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
        Context "Can generate a new certificate" {
            BeforeAll {
                $cert = New-ComputerCertificate -SelfSigned -EnableException
            }
            AfterAll {
                Remove-ComputerCertificate -Thumbprint $cert.Thumbprint -Confirm:$false
            }
            It "returns the right EnhancedKeyUsageList" {
                "$($cert.EnhancedKeyUsageList)" -match '1\.3\.6\.1\.5\.5\.7\.3\.1' | Should Be $true
            }
            It "returns the right FriendlyName" {
                "$($cert.FriendlyName)" -match 'SQL Server' | Should Be $true
            }
        }
    }
}