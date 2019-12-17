# Auto-Power-Saver-Mode

I created this script so that my PC goes into power saver performance mode, when idle. Run this script using task scheduler

You will be needing all the files in the same directory(folder) for this to work properly. 

I use this because I usually leave my system ON through the night for alarms, and even when I am not using it but I just don't want it to go to sleep.

The approach is a bit janky, and by no means I am in experienced dev. I am just a coding enthusiast and wanted to create a solution on my own.

Based on these works:
1. [Power Plan change using PowerShell](https://facility9.com/2015/07/controlling-the-windows-power-plan-with-powershell/)
2. [Auto-lock after timeout](https://gist.github.com/wendelb/1c364bb1a36ca5916ca4)
3. [Detection of Idle State](https://stackoverflow.com/a/15846912)
4. [Custom icon extractor from DLLs](https://social.technet.microsoft.com/Forums/windows/en-US/16444c7a-ad61-44a7-8c6f-b8d619381a27/using-icons-in-powershell-scripts?forum=winserverpowershell)
