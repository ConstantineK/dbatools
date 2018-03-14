$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    BeforeAll {
        $login = "dbatoolsci_removelogin"
        $password = 'MyV3ry$ecur3P@ssw0rd'
        $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
        $newlogin = New-Login -SqlInstance $script:instance1 -Login $login -Password $securePassword
    }

    It "removes the login" {
        $results = Remove-Login -SqlInstance $script:instance1 -Login $login -Confirm:$false
        $results.Status -eq "Dropped"
        $login1 = Get-login -SqlInstance $script:instance1 -login $removed
        $null -eq $login1
    }
}
