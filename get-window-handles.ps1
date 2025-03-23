# 加载必要的 .NET 类型
try {
    Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class WinAPI {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
        public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder lpString, int nMaxCount);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern int GetWindowTextLength(IntPtr hWnd);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern int GetClassName(IntPtr hWnd, System.Text.StringBuilder lpClassName, int nMaxCount);
    }
"@
    Write-Output "Add-Type 成功"
} catch {
    Write-Output "Add-Type 失败: $_"
    exit
}

# 定义函数：获取窗口标题
function Get-WindowTitle {
    param (
        [IntPtr]$hWnd
    )
    $length = [WinAPI]::GetWindowTextLength($hWnd)
    if ($length -gt 0) {
        $stringBuilder = New-Object System.Text.StringBuilder($length + 1)
        [WinAPI]::GetWindowText($hWnd, $stringBuilder, $stringBuilder.Capacity) | Out-Null
        return $stringBuilder.ToString()
    }
    return ""
}

# 定义函数：获取窗口类名
function Get-WindowClassName {
    param (
        [IntPtr]$hWnd
    )
    $stringBuilder = New-Object System.Text.StringBuilder(256)
    [WinAPI]::GetClassName($hWnd, $stringBuilder, $stringBuilder.Capacity) | Out-Null
    return $stringBuilder.ToString()
}

# 定义函数：枚举所有窗口并打印句柄、标题和类名
function Get-AllWindows {
    $windows = @()
    $enumProc = {
        param($hWnd, $lParam)
        Write-Output "枚举窗口句柄: $hWnd"
        $title = Get-WindowTitle -hWnd $hWnd
        $className = Get-WindowClassName -hWnd $hWnd
        Write-Output "窗口标题: $title"
        Write-Output "窗口类名: $className"
        $window = @{
            Handle = $hWnd
            Title = $title
            ClassName = $className
        }
        $windows += $window
        return $true
    }

    # 枚举所有窗口
    $result = [WinAPI]::EnumWindows($enumProc, [IntPtr]::Zero)
    if (-not $result) {
        $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
        Write-Output "EnumWindows 失败，错误代码: $errorCode"
    }

    return $windows
}

# 获取所有窗口并打印
$allWindows = Get-AllWindows
if ($allWindows.Count -eq 0) {
    Write-Output "未找到任何窗口"
} else {
    foreach ($window in $allWindows) {
        Write-Output "窗口句柄: $($window.Handle)"
        Write-Output "窗口标题: $($window.Title)"
        Write-Output "窗口类名: $($window.ClassName)"
        Write-Output "------------------------"
    }
}

# 手动测试 FindWindow
$notepadHandle = [WinAPI]::FindWindow("Notepad", $null)
if ($notepadHandle -eq 0) {
    Write-Output "未找到记事本窗口"
} else {
    Write-Output "找到记事本窗口，句柄: $notepadHandle"
}