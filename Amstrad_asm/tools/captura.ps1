# Captura la ventana de Caprice32 en un PNG (uso: captura.ps1 salida.png). Herramienta para Claude.
param($out)
Add-Type -AssemblyName System.Drawing
Add-Type @'
using System; using System.Runtime.InteropServices;
public class W { [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r); [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
public struct RECT { public int L,T,R,B; } }
'@
$p = Get-Process cap32 | Select-Object -First 1
[W]::SetForegroundWindow($p.MainWindowHandle) | Out-Null; Start-Sleep 1
$r = New-Object W+RECT; [W]::GetWindowRect($p.MainWindowHandle, [ref]$r) | Out-Null
$b = New-Object System.Drawing.Bitmap ($r.R-$r.L), ($r.B-$r.T)
[System.Drawing.Graphics]::FromImage($b).CopyFromScreen($r.L,$r.T,0,0,$b.Size); $b.Save($out)
