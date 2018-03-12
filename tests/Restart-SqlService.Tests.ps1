$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"
. "$PSScriptRoot\..\internal\functions\Connect-SqlInstance.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {

    Context "Command actually works" {

        $instanceName = (Connect-SqlInstance -SqlInstance $script:instance2).ServiceName
        It "restarts some services" {
            $services = Restart-SqlService -ComputerName $script:instance2 -InstanceName $instanceName -Type Agent
            $services | Should Not Be $null
            foreach ($service in $services) {
                $service.State | Should Be 'Running'
                $service.Status | Should Be 'Successful'
            }
        }

        It "restarts some services through pipeline" {
            $services = Get-SqlService -ComputerName $script:instance2 -InstanceName $instanceName -Type Agent, Engine | Restart-SqlService
            $services | Should Not Be $null
            foreach ($service in $services) {
                $service.State | Should Be 'Running'
                $service.Status | Should Be 'Successful'
            }
        }
    }
}