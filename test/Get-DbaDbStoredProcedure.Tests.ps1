<#
    The below statement stays in for every test you build.
#>
$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

<#
    Unit test is required for any command added
#>
Describe "$CommandName Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        <#
            The $paramCount is adjusted based on the parameters your command will have.

            The $defaultParamCount is adjusted based on what type of command you are writing the test for:
                - Commands that *do not* include SupportShouldProcess, set defaultParamCount    = 11
                - Commands that *do* include SupportShouldProcess, set defaultParamCount        = 13
        #>
        $paramCount = 6
        $defaultParamCount = 11
        [object[]]$params = (Get-ChildItem function:\Get-DbStoredProcedure).Parameters.Keys
        $knownParameters = 'SqlInstance', 'SqlCredential', 'Database', 'ExcludeDatabase', 'ExcludeSystemSp', 'EnableException'
        it "Should contain our specific parameters" {
            ( (Compare-Object -ReferenceObject $knownParameters -DifferenceObject $params -IncludeEqual | Where-Object SideIndicator -eq "==").Count ) | Should Be $paramCount
        }
        it "Should only contain $paramCount parameters" {
            $params.Count - $defaultParamCount | Should Be $paramCount
        }
    }
}
# Get-Noun
Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    BeforeAll {
        $server = Connect-Instance -SqlInstance $script:instance2
        $random = Get-Random
        $procName = "dbatools_getdbsp"
        $dbname = "dbatoolsci_getdbsp$random"
        $server.Query("CREATE DATABASE $dbname")
        $server.Query("CREATE PROCEDURE $procName AS SELECT 1", $dbname)
    }

    AfterAll {
        $null = Get-Database -SqlInstance $script:instance2 -Database $dbname | Remove-Database -Confirm:$false
    }

    Context "Command actually works" {
        $results = Get-DbStoredProcedure -SqlInstance $script:instance2 -Database $dbname -ExcludeSystemSp
        it "Should have standard properties" {
            $ExpectedProps = 'ComputerName,InstanceName,SqlInstance'.Split(',')
            ($results[0].PsObject.Properties.Name | Where-Object {$_ -in $ExpectedProps} | Sort-Object) | Should Be ($ExpectedProps | Sort-Object)
        }

        It "Should include test procedure: $procName" {
            ($results | Where-Object Name -eq $procName).Name | Should Be $procName
        }
        It "Should exclude system procedures" {
            ($results | Where-Object Name -eq 'sp_helpdb') | Should Be $null
        }
    }
}