$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "Get-Permission Unit Tests" -Tags "UnitTests" {
    InModuleScope sqlshell{
        Context "Validate parameters" {
            $params = (Get-ChildItem function:\Get-Permission).Parameters
            it "should have a parameter named SqlInstance" {
                $params.ContainsKey("SqlInstance") | Should Be $true
            }
            it "should have a parameter named SqlCredential" {
                $params.ContainsKey("SqlCredential") | Should Be $true
            }
            it "should have a parameter named EnableException" {
                $params.ContainsKey("EnableException") | Should Be $true
            }
        }
    }
}

Describe "Get-Permission Integration Tests" -Tag "IntegrationTests" {
    Context "parameters work" {
        it "returns server level permissions with -IncludeServerLevel" {
            $results = Get-Permission -SqlInstance $script:instance2 -IncludeServerLevel
            $results.where( {$_.Database -eq ''}).count | Should BeGreaterThan 0
        }
        it "returns no server level permissions without -IncludeServerLevel" {
            $results = Get-Permission -SqlInstance $script:instance2
            $results.where( {$_.Database -eq ''}).count | Should Be 0
        }
        it "returns no system object permissions with -NoSystemObjects" {
            $results = Get-Permission -SqlInstance $script:instance2 -NoSystemObjects
            $results.where( {$_.securable -like 'sys.*'}).count | Should Be 0
        }
        it "returns system object permissions without -NoSystemObjects" {
            $results = Get-Permission -SqlInstance $script:instance2
            $results.where( {$_.securable -like 'sys.*'}).count | Should BeGreaterThan 0
        }
    }
    Context "Validate input" {
        it "Cannot resolve hostname of computer" {
            mock Resolve-NetworkName {$null}
            {Get-ComputerSystem -ComputerName 'DoesNotExist142' -WarningAction Stop 3> $null} | Should Throw
        }
    }
}