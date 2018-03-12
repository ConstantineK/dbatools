$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

foreach ($file in (Get-ChildItem ( Join-Path $ScriptDir ".\internal") -Filter "*.ps1")){
	. $file.FullName
}

foreach ($file in (Get-ChildItem ( Join-Path $ScriptDir ".\function" ) -Filter "*.ps1" )){
	. $file.FullName
}