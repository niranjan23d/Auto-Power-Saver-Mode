#Author: Niranjan Dixit
#This script is based on the the code by wendelb here: https://gist.github.com/wendelb/1c364bb1a36ca5916ca4

# use task scheduler and use this line below to execute at every logon session
# 	powershell.exe -windowstyle hidden -executionpolicy Unrestricted P:\ATH\TO\auto-power-plan-swticher.ps1
#
# `-windowstyle hidden` will make your PowerShell disappear/run in background
# `-executionpolicy Unrestricted` will enable this PowerShell process to allow non-signed scripts

# This is the only setting: How long before going into power saver?
# Alternative examples:
# * -Seconds 10 ( = 10 Seconds)
# * -Minutes 10 ( = 10 Minutes)
# * -Hours 10 ( = 10 Hours)

$idle_timeout = New-TimeSpan -Minutes 10

# DO NOT CHANGE ANYTHING BELOW THIS LINE
##########################################################
# This snippet is from http://stackoverflow.com/a/15846912

Add-Type @'
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
namespace PInvoke.Win32 {
    public static class UserInput {
        [DllImport("user32.dll", SetLastError=false)]
        private static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);
        [StructLayout(LayoutKind.Sequential)]
        private struct LASTINPUTINFO {
            public uint cbSize;
            public int dwTime;
        }
        public static DateTime LastInput {
            get {
                DateTime bootTime = DateTime.UtcNow.AddMilliseconds(-Environment.TickCount);
                DateTime lastInput = bootTime.AddMilliseconds(LastInputTicks);
                return lastInput;
            }
        }
        public static TimeSpan IdleTime {
            get {
                return DateTime.UtcNow.Subtract(LastInput);
            }
        }
        public static int LastInputTicks {
            get {
                LASTINPUTINFO lii = new LASTINPUTINFO();
                lii.cbSize = (uint)Marshal.SizeOf(typeof(LASTINPUTINFO));
                GetLastInputInfo(ref lii);
                return lii.dwTime;
            }
        }

    }
}
'@

#End snippet
#Helper: Is device still in Power Saver?
$pwrSvr = 0;
#Have you been notified?
$showNotif = 0;

do {
	# 1st: How long is your computer currently idle?
	$idle_time = [PInvoke.Win32.UserInput]::IdleTime;

	# Your computer is not in Power Saver, but idle time is longer than allowed? -> Switch to Power Saver!
	if (($pwrSvr -eq 0) -And ($idle_time -gt $idle_timeout)) {
		#Switch to Power Saver
        Try {
            $LowPerf = powercfg -l | %{if($_.contains("Power Saver")) {$_.split()[3]}}    #gets list of available plans
            $CurrPlan = $(powercfg -getactivescheme).split()[3]    #gets active plan
            if ($CurrPlan -ne $LowPerf) 
            {
                powercfg -setactive $LowPerf  #set the power saver plan
                if($showNotif -eq 0)    #show notification ONLY if not notified.
                {
                    powershell "C:\Users\niran\APS\powerSaverNotify.ps1"   #use your own FULL path for "powerSaverNotify.ps1"
                }
                $showNotif = 1;    #you're now notified. with this, the notification won't appear every 5 seconds as it checks the power state.
            }
            } 
        Catch {
            Write-Warning -Message "Unable to set power plan to Power Saver"
        }
		# Setting $pwrSvr to 1 will prevent it from going into power saver mode every 5 seconds
		$pwrSvr = 1;
        
	}

	# Your computer is idle for less than the allowed time -> in most cases this means it is in High performance mode and
	# therefore ready to go into power savving mode again!
	if ($idle_time -lt $idle_timeout) {
        Try {
            $HighPerf = powercfg -l | %{if($_.contains("High Performance")) {$_.split()[3]}}
            if ($CurrPlan -ne $HIghPerf) 
            {
                powercfg -setactive $HighPerf    #set the high performance plan
                if($showNotif -eq 1)    #show notification ONLY if not notified.
                {
	                powershell "C:\Users\niran\APS\highPerfNotify.ps1"    ##use your own FULL path for "highPerfNotify.ps1"
                }
                $showNotif = 0;    #you're now notified. with this, the notification won't appear every 5 seconds as it checks the power state.
            } 
            }
        Catch {
            Write-Warning -Message "Unable to set power plan to High Performance"
        }
        $pwrSvr = 0; #Setting $pwrSvr to 0 will prevent it from going into high performance mode every 5 seconds
	}

	# Save the environment. Don't use 100% of a single CPU just for idle checking :)
    Start-Sleep -Seconds 10
}
while (1 -eq 1) #run for eternity