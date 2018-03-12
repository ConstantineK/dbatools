$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "UnitTests" {

    Context "Rename a Database" {
        $History = Get-BackupInformation -Import -Path $PSScriptRoot\..\tests\ObjectDefinitions\BackupRestore\RawInput\ContinuePointTest.xml
        $output = $history | Format-BackupInformation -ReplaceDatabaseName 'Pester'
        It "Should have a database name of Pester" {
            ($output | Where-Object {$_.Database -ne 'Pester'}).count | Should be 0
        }
        It "Should have renamed datafiles as well" {
            ($output | Select-Object -ExpandProperty filelist | Where-Object {$_.PhysicalName -like '*ContinuePointTest*'}).count
        }

    }

    Context "Test it works as a parameter as well" {
        $History = Get-BackupInformation -Import -Path $PSScriptRoot\..\tests\ObjectDefinitions\BackupRestore\RawInput\ContinuePointTest.xml
        $output = Format-BackupInformation -BackupHistory $History -ReplaceDatabaseName 'Pester'
        It "Should have a database name of Pester" {
            ($output | Where-Object {$_.Database -ne 'Pester'}).count | Should be 0
        }
        It "Should have renamed datafiles as well" {
            ($out | Select-Object -ExpandProperty filelist | Where-Object {$_.PhysicalName -like 'ContinuePointTest'}).count | Should Be 0
        }
    }

    Context "Rename 2 dbs using a hash" {
        $History = Get-BackupInformation -Import -Path $PSScriptRoot\..\tests\ObjectDefinitions\BackupRestore\RawInput\ContinuePointTest.xml
        $History += Get-BackupInformation -Import -Path $PSScriptRoot\..\tests\ObjectDefinitions\BackupRestore\RawInput\RestoreTimeClean.xml
        $output = Format-BackupInformation -BackupHistory $History -ReplaceDatabaseName @{'ContinuePointTest' = 'Spiggy'; 'RestoreTimeClean' = 'Eldritch'}
        It "Should have no databases other than spiggy and eldritch" {
            ($output | Where-Object {$_.Database -notin ('Spiggy', 'Eldritch')}).count | Should be 0
        }
        It "Should have renamed all RestoreTimeCleans to Eldritch" {
            ($Output | Where-Object {$_.OriginalDatabase -eq 'RestoreTimeClean'} | Where-Object {$_.Database -ne 'Eldritch'}).count | Should be 0
        }
        It "Should have renamed all the RestoreTimeClean files to Eldritch" {
            ($out | Where-Object {$_.OriginalDatabase -eq 'RestoreTimeClean'} | Select-Object -ExpandProperty filelist | Where-Object {$_.PhysicalName -like 'RestoreTimeClean'}).count | Should Be 0
            ($out | Where-Object {$_.OriginalDatabase -eq 'RestoreTimeClean'} | Select-Object -ExpandProperty filelist | Where-Object {$_.PhysicalName -like 'eldritch'}).count | Should Be ($out | Where-Object {$_.OriginalDatabase -eq 'ContinuePointTest'} | Select-Object -ExpandProperty filelist).count

        }
        It "Should have renamed all ContinuePointTest to Spiggy" {
            ($Output | Where-Object {$_.OriginalDatabase -eq 'ContinuePointTest'} | Where-Object {$_.Database -ne 'Spiggy'}).count | Should be 0
        }
        It "Should have renamed all the ContinuePointTest files to Spiggy" {
            ($out | Where-Object {$_.OriginalDatabase -eq 'ContinuePointTest'} | Select-Object -ExpandProperty filelist | Where-Object {$_.PhysicalName -like 'ContinuePointTest'}).count | Should Be 0
            ($out | Where-Object {$_.OriginalDatabase -eq 'ContinuePointTest'} | Select-Object -ExpandProperty filelist | Where-Object {$_.PhysicalName -like 'spiggy'}).count | Should Be ($out | Where-Object {$_.OriginalDatabase -eq 'ContinuePointTest'} | Select-Object -ExpandProperty filelist).count

        }
    }

    Context "Rename 1 dbs using a hash" {
        $History = Get-BackupInformation -Import -Path $PSScriptRoot\..\tests\ObjectDefinitions\BackupRestore\RawInput\ContinuePointTest.xml
        $History += Get-BackupInformation -Import -Path $PSScriptRoot\..\tests\ObjectDefinitions\BackupRestore\RawInput\RestoreTimeClean.xml
        $output = Format-BackupInformation -BackupHistory $History -ReplaceDatabaseName @{'ContinuePointTest' = 'Alice'}
        It "Should have no databases other than spiggy and eldritch" {
            ($output | Where-Object {$_.Database -notin ('RestoreTimeClean', 'Alice')}).count | Should be 0
        }
        It "Should have left RestoreTimeClean alone" {
            ($Output | Where-Object {$_.OriginalDatabase -eq 'RestoreTimeClean'} | Where-Object {$_.Database -ne 'RestoreTimeClean'}).count | Should be 0
        }
        It "Should have renamed all ContinuePointTest to Alice" {
            ($Output | Where-Object {$_.OriginalDatabase -eq 'ContinuePointTest'} | Where-Object {$_.Database -ne 'Alice'}).count | Should be 0
        }
        It "Should have renamed all the ContinuePointTest files to Alice" {
            ($Output | Where-Object {$_.OriginalDatabase -eq 'ContinuePointTest'} | Select-Object -ExpandProperty filelist | Where-Object {$_.PhysicalName -like 'ContinuePointTest'}).count | Should Be 0
            ($Output | Where-Object {$_.OriginalDatabase -eq 'ContinuePointTest'} | Select-Object -ExpandProperty filelist | Where-Object {$_.PhysicalName -like 'alice'}).count | Should Be ($out | Where-Object {$_.OriginalDatabase -eq 'ContinuePointTest'} | Select-Object -ExpandProperty filelist).count
        }
    }

    Context "Check DB Name prefix and suffix" {
        $History = Get-BackupInformation -Import -Path $PSScriptRoot\..\tests\ObjectDefinitions\BackupRestore\RawInput\ContinuePointTest.xml
        $output = $history | Format-BackupInformation -DatabaseNamePrefix PREFIX
        It "Should have prefixed all db names" {
            ($Output | Where-Object {$_.Database -like 'PREFIX*'}).count | Should be $output.count
        }

    }

    Context "Check DataFileDirectory moves all files" {
        $History = Get-BackupInformation -Import -Path $PSScriptRoot\..\tests\ObjectDefinitions\BackupRestore\RawInput\ContinuePointTest.xml
        $History += Get-BackupInformation -Import -Path $PSScriptRoot\..\tests\ObjectDefinitions\BackupRestore\RawInput\RestoreTimeClean.xml
        $output = Format-BackupInformation -BackupHistory $History -DataFileDirectory c:\restores

        It "Should have move ALL files to c:\restores\" {
            (($Output | Select-Object -ExpandProperty Filelist).PhysicalName | split-path | Where-Object {$_ -ne 'c:\restores'}).count | Should Be 0
        }
    }

    Context "Check DataFileDirectory and LogFileDirectory work independently" {
        $History = Get-BackupInformation -Import -Path $PSScriptRoot\..\tests\ObjectDefinitions\BackupRestore\RawInput\ContinuePointTest.xml
        $History += Get-BackupInformation -Import -Path $PSScriptRoot\..\tests\ObjectDefinitions\BackupRestore\RawInput\RestoreTimeClean.xml
        $output = Format-BackupInformation -BackupHistory $History -DataFileDirectory c:\restores\ -LogFileDirectory c:\logs

        It "Should  have moved all data files to c:\restores\" {
            (($Output | Select-Object -ExpandProperty Filelist | Where-Object {$_.Type -eq 'D'}).PhysicalName | split-path | Where-Object {$_ -ne 'c:\restores'}).count | Should Be 0
        }
        It "Should have moved all log files to c:\logs\" {
            (($Output | Select-Object -ExpandProperty Filelist | Where-Object {$_.Type -eq 'L'}).PhysicalName | split-path | Where-Object {$_ -ne 'c:\logs'}).count | Should Be 0
        }
    }

    Context "Check LogFileDirectory works for just logfiles" {
        $History = Get-BackupInformation -Import -Path $PSScriptRoot\..\tests\ObjectDefinitions\BackupRestore\RawInput\ContinuePointTest.xml
        $History += Get-BackupInformation -Import -Path $PSScriptRoot\..\tests\ObjectDefinitions\BackupRestore\RawInput\RestoreTimeClean.xml
        $Output = Format-BackupInformation -BackupHistory $History -DataFileDirectory c:\restores\ -LogFileDirectory c:\logs

        It "Should not have moved all data files to c:\restores\" {
            (($Output | Select-Object -ExpandProperty Filelist | Where-Object {$_.Type -eq 'D'}).PhysicalName | split-path | Where-Object {$_ -eq 'c:\logs'}).count | Should Be 0
        }
        It "Should have moved all log files to c:\logs\" {
            (($Output | Select-Object -ExpandProperty Filelist | Where-Object {$_.Type -eq 'L'}).PhysicalName | split-path | Where-Object {$_ -ne 'c:\logs'}).count | Should Be 0
        }
    }

    Context "Test RebaseBackupFolder" {
        $History = Get-BackupInformation -Import -Path $PSScriptRoot\..\tests\ObjectDefinitions\BackupRestore\RawInput\ContinuePointTest.xml
        $History += Get-BackupInformation -Import -Path $PSScriptRoot\..\tests\ObjectDefinitions\BackupRestore\RawInput\RestoreTimeClean.xml
        $Output = Format-BackupInformation -BackupHistory $History -RebaseBackupFolder c:\backups\

        It "Should not have moved all backup files to c:\backups" {
            ($Output | Select-Object -ExpandProperty FullName | split-path | Where-Object {$_ -eq 'c:\backups'}).count | Should Be 0
        }

    }

    Context "Test everything all at once" {
        $History = Get-BackupInformation -Import -Path $PSScriptRoot\..\tests\ObjectDefinitions\BackupRestore\RawInput\ContinuePointTest.xml
        $output = $history | Format-BackupInformation -ReplaceDatabaseName 'Pester' -DataFileDirectory c:\restores -LogFileDirectory c:\logs\ -RebaseBackupFolder c:\backups\
        It "Should have a database name of Pester" {
            ($output | Where-Object {$_.Database -ne 'Pester'}).count | Should be 0
        }
        It "Should have renamed datafiles as well" {
            ($output | Select-Object -ExpandProperty filelist | Where-Object {$_.PhysicalName -like '*ContinuePointTest*'}).count
        }
        It "Should  have moved all data files to c:\restores\" {
            (($Output | Select-Object -ExpandProperty Filelist | Where-Object {$_.Type -eq 'D'}).PhysicalName | split-path | Where-Object {$_ -ne 'c:\restores'}).count | Should Be 0
        }
        It "Should have moved all log files to c:\logs\" {
            (($Output | Select-Object -ExpandProperty Filelist | Where-Object {$_.Type -eq 'L'}).PhysicalName | split-path | Where-Object {$_ -ne 'c:\logs'}).count | Should Be 0
        }
        It "Should not have moved all backup files to c:\backups" {
            ($Output | Select-Object -ExpandProperty FullName | split-path | Where-Object {$_ -eq 'c:\backups'}).count | Should Be 0
        }

    }
}