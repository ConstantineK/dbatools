$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Can remove a certificate" {
        BeforeAll {
            $null = Add-ComputerCertificate -Path $script:appveyorlabrepo\certificates\localhost.crt -Confirm:$false
            $thumbprint = "29C469578D6C6211076A09CEE5C5797EEA0C2713"
        }

        $results = Remove-ComputerCertificate -Thumbprint $thumbprint -Confirm:$false

        It "returns the store Name" {
            $results.Store -eq "LocalMachine" | Should Be $true
        }
        It "returns the folder Name" {
            $results.Folder -eq "My" | Should Be $true
        }

        It "reports the proper status of Removed" {
            $results.Status -eq "Removed" | Should Be $true
        }

        It "really removed it" {
            $results = Get-ComputerCertificate -Thumbprint $thumbprint
            $results | Should Be $null
        }
    }
}