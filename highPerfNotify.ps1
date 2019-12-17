#The below code snippet is to extract extract icons from shell32.dll, imageres.dll, explorer.exe, etc...

$code = @"
using System;
using System.Drawing;
using System.Runtime.InteropServices;

namespace System
{
	public class IconExtractor
	{

	 public static Icon Extract(string file, int number, bool largeIcon)
	 {
	  IntPtr large;
	  IntPtr small;
	  ExtractIconEx(file, number, out large, out small, 1);
	  try
	  {
	   return Icon.FromHandle(largeIcon ? large : small);
	  }
	  catch
	  {
	   return null;
	  }

	 }
	 [DllImport("Shell32.dll", EntryPoint = "ExtractIconExW", CharSet = CharSet.Unicode, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
	 private static extern int ExtractIconEx(string sFile, int iIndex, out IntPtr piLargeVersion, out IntPtr piSmallVersion, int amountIcons);

	}
}
"@
#End Snippet

#The below code generates the notifiaction with the icon
Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$form = New-Object System.Windows.Forms.NotifyIcon
$form.Icon = [System.IconExtractor]::Extract("explorer.exe", 5, $true) #invoke icon extractor
$form.Visible = $true 
$form.BalloonTipText = "Power plan changed to High Performance"
$form.ShowBalloonTip(1000)
