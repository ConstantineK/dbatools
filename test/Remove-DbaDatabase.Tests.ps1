$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Should not munge system databases unless explicitly told to." {

        $dbs = @( "master", "model", "tempdb", "msdb" )

        It "Should not attempt to remove system databases." {
            foreach ($db in $dbs) {
                $db1 = Get-Database -SqlInstance $script:instance1 -Database $db
                Remove-Database -Confirm:$false -SqlInstance $script:instance1 -Database $db
                $db2 = Get-Database -SqlInstance $script:instance1 -Database $db
                $db2.Name | Should Be $db1.Name
            }
        }

        It "Should not take system databases offline or change their status." {
            foreach ($db in $dbs) {
                $db1 = Get-Database -SqlInstance $script:instance1 -Database $db
                Remove-Database -Confirm:$false -SqlInstance $script:instance1 -Database $db
                $db2 = Get-Database -SqlInstance $script:instance1 -Database $db
                $db2.Status | Should Be $db1.Status
                $db2.IsAccessible | Should Be $db1.IsAccessible
            }
        }
    }
    Context "Should remove user databases and return useful errors if it cannot." {
        It "Should remove a non system database." {
            Remove-Database -Confirm:$false -SqlInstance $script:instance1 -Database singlerestore
            Get-Process -SqlInstance $script:instance1 -Database singlerestore | Stop-Process
            Restore-Database -SqlInstance $script:instance1 -Path $script:appveyorlabrepo\singlerestore\singlerestore.bak -WithReplace
            (Get-Database -SqlInstance $script:instance1 -Database singlerestore).IsAccessible | Should Be $true
            Remove-Database -Confirm:$false -SqlInstance $script:instance1 -Database singlerestore
            Get-Database -SqlInstance $script:instance1 -Database singlerestore | Should Be $null
        }
    }
    Context "Should remove restoring database and return useful errors if it cannot." {
        It "Should remove a non system database." {
            Remove-Database -Confirm:$false -SqlInstance $script:instance1 -Database singlerestore
            Get-Process -SqlInstance $script:instance1 -Database singlerestore | Stop-Process
            Restore-Database -SqlInstance $script:instance1 -Path $script:appveyorlabrepo\singlerestore\singlerestore.bak -WithReplace -NoRecovery
            (Connect-Instance -SqlInstance $script:instance1).Databases['singlerestore'].IsAccessible | Should Be $false
            Remove-Database -Confirm:$false -SqlInstance $script:instance1 -Database singlerestore
            Get-Database -SqlInstance $script:instance1 -Database singlerestore | Should Be $null
        }
    }
}
