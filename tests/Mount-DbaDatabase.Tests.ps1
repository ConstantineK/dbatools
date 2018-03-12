$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {

    Context "Setup removes, restores and backups on the local drive for Mount-Database" {
        $null = Get-Database -SqlInstance $script:instance1 -NoSystemDb | Remove-Database -Confirm:$false
        $null = Restore-Database -SqlInstance $script:instance1 -Path $script:appveyorlabrepo\detachattach\detachattach.bak -WithReplace
        $null = Get-Database -SqlInstance $script:instance1 -Database detachattach | Backup-Database -Type Full
        $null = Detach-Database -SqlInstance $script:instance1 -Database detachattach -Force
    }

    Context "Attaches a single database and tests to ensure the alias still exists" {
        $results = Attach-Database -SqlInstance $script:instance1 -Database detachattach

        It "Should return success" {
            $results.AttachResult | Should Be "Success"
        }

        It "Should return that the database is only Database" {
            $results.Database | Should Be "detachattach"
        }

        It "Should return that the AttachOption default is None" {
            $results.AttachOption | Should Be "None"
        }
    }

    $null = Get-Database -SqlInstance $script:instance1 -NoSystemDb | Remove-Database -Confirm:$false
}