$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Disks are properly retreived" {
        $results = Get-DiskSpace -ComputerName $env:COMPUTERNAME
        It "returns at least the system drive" {
            $results.Name -contains "$env:SystemDrive\" | Should Be $true
        }

        $results = Get-DiskSpace -ComputerName $env:COMPUTERNAME | Where-Object Name -eq "$env:SystemDrive\"
        It "has some valid properties" {
            $results.BlockSize -gt 0 | Should Be $true
            $results.SizeInGB -gt 0 | Should Be $true
        }
    }
}