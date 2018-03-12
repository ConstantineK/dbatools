$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    BeforeAll {
        $login = "dbatoolsci_renamelogin"
        $renamed = "dbatoolsci_renamelogin2"
        $password = 'MyV3ry$ecur3P@ssw0rd'
        $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
        $newlogin = New-Login -SqlInstance $script:instance1 -Login $login -Password $securePassword
    }
    AfterAll {
        Stop-Process -SqlInstance $script:instance1 -Login $renamed
        (Get-login -SqlInstance $script:instance1 -Login $renamed).Drop()
    }

    It "renames the login" {
        $results = Rename-Login -SqlInstance $script:instance1 -Login $login -NewLogin $renamed
        $results.Status -eq "Successful"
        $results.OldLogin = $login
        $results.NewLogin = $renamed
        $login1 = Get-login -SqlInstance $script:instance1 -login $renamed
        $null -ne $login1
    }
}
