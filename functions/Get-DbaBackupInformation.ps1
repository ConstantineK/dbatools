function Get-DbaBackupInformation {
    <#
    .SYNOPSIS
        Restores a SQL Server Database from a set of backupfiles
    
    .DESCRIPTION
        Upon bein passed a list of potential backups files this command will scan the files, select those that contain SQL Server
        backup sets. It will then filter those files down to a set 

        The function defaults to working on a remote instance. This means that all paths passed in must be relative to the remote instance.
        XpDirTree will be used to perform the file scans
                
        Various means can be used to pass in a list of files to be considered. The default is to non recursively scan the folder
        passed in.
    
    .PARAMETER Path
        Path to SQL Server backup files.
        
        Paths passed in as strings will be scanned using the desired method, default is a non recursive folder scan
        Accepts multiple paths seperated by ','
        
        Or it can consist of FileInfo objects, such as the output of Get-ChildItem or Get-Item. This allows you to work with
        your own filestructures as needed
    
    .PARAMETER SqlInstance
        The SQL Server instance to be used to read the headers of the backup files
    
    .PARAMETER SqlCredential
        Allows you to login to servers using SQL Logins as opposed to Windows Auth/Integrated/Trusted.
    
    .PARAMETER DatabaseName
        An arrary of Database Names to filter by. If empty all databases are returned.

    .PARAMETER SourceInstance
        If provided only backup originating from this destination will be returned. This SQL instance will not be connected to or involved in this work
    
        .PARAMETER XpDirTree
        Switch that indicated file scanning should be performed by the SQL Server instance using xp_dirtree
        This will scan recursively from the passed in path
        You must have sysadmin role membership on the instance for this to work.
    
    .PARAMETER XpNoRecurse
        If specified, prevents the XpDirTree process from recursing (it's default behaviour)

	.PARAMETER DirectoryRecurse
        If specified the specified directory will be recursed into
    
    .PARAMETER Anonymise
        If specified we will output the results with ComputerName, InstanceName, Database, UserName, and Paths hashed out
        This options is mainly for use if we need you to submit details for fault finding to the dbatools team
    
    .PARAMETER ExportPath
        If specified the ouput will export via CliXml format to the specified file. This allows you to store the backup history object for later usage, or move it between computers
    
    .PARAMETER NoClobber
        If specified will stop Export from overwriting an existing file, the default is to overwrite

    .PARAMETER PassThru
        When data is exported the cmdlet will return no other output, this switch means it will also return the normal output which can be then piped into another command
    
    .PARAMETER EnableException
        Replaces user friendly yellow warnings with bloody red exceptions of doom!
        Use this if you want the function to throw terminating errors you want to catch.
    
	.PARAMETER Confirm
        Prompts to confirm certain actions
    
    .PARAMETER WhatIf
        Shows what would happen if the command would execute, but does not actually perform the command
    
    .EXAMPLE
        Get-DbaBackupInformation -SqlInstance Server1 -Path c:\backups\ -DirectoryRecurse

        Will use the Server1 instance to recursively read all backup files under c:\backups, and return a dbatool BackupHistory object

    .EXAMPLE
        Get-DbaBackupInformation -SqlInstance Server1 -Path c:\backups\ -DirectoryRecurse -ExportPath c:\store\BackupHistory.xml
        
        #Copy the file  c:\store\BackupHistory.xml to another machine via preferred technique, and the on 2nd machine:
        
        $backups = Import-CliXml -Path  c:\store\BackupHistory.xml
        $backups | Restore-DbaDatabase -SqlInstance Server2 -TrustDbBackupHistory

        This allows you to move backup history across servers, or to preserve backuphistory even after the original server has been purged
    
    .EXAMPLE
        Get-DbaBackupInformation -SqlInstance Server1 -Path c:\backups\ -DirectoryRecurse -ExportPath c:\store\BackupHistory.xml -PassThru !
                Restore-DbaDatabse -SqlInstance Server2 -TrustDbBackupHistory
        
        In this example we gather backup information, export it to an xml file, and then pass it on through to Restore-DbaDatabase
        This allows us to repeat the restore without having to scan all the backup files again

    .EXAMPLE
        Get-ChildItem c:\backups\ -recurse -files |
            Where {$_.extension -in ('.bak','.trn') -and $_.LastWriteTime -gt (get-date).AddMonths(-1)} |
            Get-DbaBackupInformation -SqlInstance Server1 -ExportPath c:\backupHistory.xml
        
        This lets you keep a record of all backup history from the last month on hand to speed up refreshes 
    
    .EXAMPLE
        $Backups = Get-DbaBackupInformation -SqlInstance Server1 -Path \\network\backupps
        $Backups += Get-DbaBackupInformation -SqlInstance Server2 -XpDirTree -Path c:\backups

        Scan the unc folder \\network\backups with Server1, and then scan the C:\backups folder on 
        Server2 using xp_dirtree, adding the results to the first set.

    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object[]]$Path,
        [parameter(Mandatory = $true)]
        [Alias("ServerInstance", "SqlServer")]
        [DbaInstanceParameter]$SqlInstance,
        [PSCredential][System.Management.Automation.CredentialAttribute()]$SqlCredential,
        [string[]]$DatabaseName,
        [string[]]$SourceInstance,
        [switch]$XpNoRecurse,
        [Switch]$XpDirTree,
        [switch]$DirectoryRecurse,
        [switch]$EnableException,
        [string]$ExportPath,
        [switch][Alias('Anonymize')]$Anonymise,
        [Switch]$NoClobber,
        [Switch]$PassThru
      
    )
    begin {

        Function Hash-String{
            param(
                [String]$InString,
                [boolean]$hash
                )
            if ($true -eq $hash){
                $StringBuilder = New-Object System.Text.StringBuilder
                [System.Security.Cryptography.HashAlgorithm]::Create("md5").ComputeHash([System.Text.Encoding]::UTF8.GetBytes($InString))|%{
                    [Void]$StringBuilder.Append($_.ToString("x2"))
                }
                    return $StringBuilder.ToString()
            } else {
               return $InString
            }
        } 
        Write-Message -Level InternalComment -Message "Starting"
        Write-Message -Level Debug -Message "Parameters bound: $($PSBoundParameters.Keys -join ", ")"

            if (Test-Bound -ParameterName ExportPath){
            if ($true -eq $NoClobber) {
                if (Test-Path $ExportPath){
                    Stop-Function -Message "$ExportPath exists and NoClobber set" 
                    return
                }
            }
        }
        try {
            $server = Connect-SqlInstance -SqlInstance $SqlInstance -SqlCredential $SqlCredential
        }
        catch {
            Stop-Function -Message "Failure" -Category ConnectionError -ErrorRecord $_ -Target $instance -Continue
            return
        }
    }
    process {
        if (Test-FunctionInterrupt) { return }
        $Files = @()
        if ($XpDirTree -eq $true){
            ForEach ($f in $path) {
                $Files += Get-XpDirTreeRestoreFile -Path $f -SqlInstance $SqlInstance -SqlCredential $SqlCredential
            }
        } 
        else {
            ForEach ($f in $path) {
                $Files += Get-ChildItem -Path $f -file -Recurse:$recurse
            }
        }
        
        $FileDetails = $Files | Read-DbaBackupHeader -SqlInstance $SqlInstance -SqlCredential $sqlcredential
        if (Test-Bound 'SourceInstance') {
            $FileDetails = $FileDetails | Where-Object {$_.ServerName -in $SourceInstance}
        }

        if (Test-Bound 'DatabaseName') {
            $FileDetails = $FileDetails | Where-Object {$_.DatabaseName -in $DatabaseName}
        }

        $groupdetails = $FileDetails | group-object -Property BackupSetGUID
        $groupResults = @()
        Foreach ($Group in $GroupDetails){
            $historyObject = New-Object Sqlcollaborative.Dbatools.Database.BackupHistory
            $historyObject.ComputerName = Hash-String -InString $group.group[0].MachineName -Hash $Anonymise
            $historyObject.InstanceName = Hash-String -InString $group.group[0].ServiceName -Hash $Anonymise
            $historyObject.SqlInstance = Hash-String -InString $group.group[0].ServerName -Hash $Anonymise
            $historyObject.Database = Hash-String -InString $group.Group[0].DatabaseName -Hash $Anonymise
            $historyObject.UserName = Hash-String -InString $group.Group[0].UserName -Hash $Anonymise
            $historyObject.Start = [DateTime]$group.Group[0].BackupStartDate 
            $historyObject.End = [DateTime]$group.Group[0].BackupFinishDate
            $historyObject.Duration = ([DateTime]$group.Group[0].BackupFinishDate - [DateTime]$group.Group[0].BackupStartDate).Seconds
            $historyObject.Path = Hash-String -InString  $Group.Group.BackupPath -Hash $Anonymise
            $historyObject.TotalSize = (Measure-Object $Group.Group.BackupSizeMB -sum).sum
            $historyObject.Type = $group.Group[0].BackupTypeDescription
            $historyObject.BackupSetId = $group.group[0].BackupSetGUID
            $historyObject.DeviceType = 'Disk'
            $historyObject.FullName = Hash-String -InString $Group.Group.BackupPath -Hash $Anonymise
            $historyObject.FileList = $Group.Group[0].FileList
            $historyObject.Position = $group.Group[0].Position
            $historyObject.FirstLsn = $group.Group[0].FirstLSN
            $historyObject.DatabaseBackupLsn = $group.Group[0].DatabaseBackupLSN
            $historyObject.CheckpointLsn = $group.Group[0].CheckpointLSN
            $historyObject.LastLsn = $group.Group[0].LastLsn
            $historyObject.SoftwareVersionMajor = $group.Group[0].SoftwareVersionMajor
            $groupResults += $historyObject
        }
        if ((Test-Bound -parameterName exportpath) -and $null -ne $ExportPath) {
            $groupResults | Export-CliXml -Path $ExportPath -Depth 5 -NoClobber:$NoClobber
            if ($true -ne $PassThru){
                return
            }
        }
        $groupResults | Sort-Object -Property End -Descending
    }

    
}