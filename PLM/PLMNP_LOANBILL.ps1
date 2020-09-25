Param(
    [string]$PLMDatabase,
    [string]$FileName
)
$ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$File=$ScriptPath + '\Input\' + $FileName
$Program= $ScriptPath + '\LMSNP_MCAP_LOANBILL.bat'
ForEach($Loan in (Import-CSV $File))
{
    cmd /C $Program $PLMDatabase $Loan.Loan $Loan.FromDate $Loan.ToDate
} 
