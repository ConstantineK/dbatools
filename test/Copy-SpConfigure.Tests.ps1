$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Copy config with the same properties." {
        BeforeAll {
            $sourceconfig = (Get-SpConfigure -SqlInstance $script:instance1 -ConfigName RemoteQueryTimeout).ConfiguredValue
            $destconfig = (Get-SpConfigure -SqlInstance $script:instance2 -ConfigName RemoteQueryTimeout).ConfiguredValue
            # Set it so they don't match
            if ($sourceconfig -and $destconfig) {
                $newvalue = $sourceconfig + $destconfig
                $null = Set-SpConfigure -SqlInstance $script:instance2 -ConfigName RemoteQueryTimeout -Value $newvalue
            }
        }
        AfterAll {
            if ($destconfig -and $destconfig -ne $sourceconfig) {
                $null = Set-SpConfigure -SqlInstance $script:instance2 -ConfigName RemoteQueryTimeout -Value $destconfig
            }
        }

        It "starts with different values" {
            $config1 = Get-SpConfigure -SqlInstance $script:instance1 -ConfigName RemoteQueryTimeout
            $config2 = Get-SpConfigure -SqlInstance $script:instance2 -ConfigName RemoteQueryTimeout
            $config1.ConfiguredValue -ne $config2.ConfiguredValue | Should be $true
        }

        It "copied successfully" {
            $results = Copy-SpConfigure -Source $script:instance1 -Destination $script:instance2 -ConfigName RemoteQueryTimeout
            $results.Status | Should Be "Successful"
        }

        It "retains the same properties" {
            $config1 = Get-SpConfigure -SqlInstance $script:instance1 -ConfigName RemoteQueryTimeout
            $config2 = Get-SpConfigure -SqlInstance $script:instance2 -ConfigName RemoteQueryTimeout
            $config1.ConfiguredValue | Should be $config2.ConfiguredValue
        }

        It "didn't modify the source" {
            $newconfig = (Get-SpConfigure -SqlInstance $script:instance1 -ConfigName RemoteQueryTimeout).ConfiguredValue
            $newconfig -eq $sourceconfig | Should Be $true
        }
    }
}
