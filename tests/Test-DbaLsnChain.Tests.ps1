$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Unit Tests" -Tag 'UnitTests' {
    InModuleScope sqlshell{
        Context "General Diff restore" {
            $Header = ConvertFrom-Json -InputObject (Get-Content $PSScriptRoot\..\tests\ObjectDefinitions\BackupRestore\RawInput\DiffRestore.json -raw)
            $header | Add-Member -Type NoteProperty -Name FullName -Value 1

            $filteredFiles = $header | Select-BackupInformation
            It "Should Return 7" {
                $FilteredFiles.count | should be 7
            }
            It "Should return True" {
                $Output = Test-LsnChain -FilteredRestoreFiles $FilteredFiles -WarningAction SilentlyContinue
                $Output | Should be True
            }
            $Header = ConvertFrom-Json -InputObject (Get-Content $PSScriptRoot\..\tests\ObjectDefinitions\BackupRestore\RawInput\DiffRestore.json -raw)
            $header = $Header | Where-Object { $_.BackupTypeDescription -ne 'Database Differential' }
            $header | Add-Member -Type NoteProperty -Name FullName -Value 1

            $FilteredFiles = $Header | Select-BackupInformation
            It "Should return true if we remove diff backup" {
                $Output = Test-LsnChain -WarningAction SilentlyContinue -FilteredRestoreFiles ($FilteredFiles | Where-Object { $_.BackupTypeDescription -ne 'Database Differential' })
                $Output | Should be True
            }

            It "Should return False (faked lsn)" {
                $FilteredFiles[4].FirstLsn = 2
                $FilteredFiles[4].LastLsn = 1
                $Output = Test-LsnChain -WarningAction SilentlyContinue -FilteredRestoreFiles $FilteredFiles
                $Output | Should be $False
            }
        }
    }
}