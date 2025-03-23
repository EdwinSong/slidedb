# 设置控制台编码为 UTF-8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 加载 System.Windows.Forms 程序集
Add-Type -AssemblyName System.Windows.Forms

# 定义 WinAPI 类（只定义一次）
if (-not ([System.Management.Automation.PSTypeName]'WinAPI').Type) {
    Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class WinAPI {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
    }
"@
}

# 定义函数：启动Edge并移动到指定显示器
function Start-EdgeOnDisplay {
    param (
        [int]$DisplayIndex
    )

    # 启动Edge浏览器
    $edgeProcess = Start-Process "msedge" -PassThru

    # 等待Edge窗口加载完成
    Start-Sleep -Seconds 5  # 增加等待时间

    # 获取Edge窗口句柄
    $edgeWindow = $null
    $retryCount = 0
    while ($retryCount -lt 5) {
        $edgeWindow = Get-Process | Where-Object { $_.Id -eq $edgeProcess.Id } | ForEach-Object { $_.MainWindowHandle }
        if ($edgeWindow -ne 0) {
            break
        }
        Start-Sleep -Seconds 1
        $retryCount++
    }

    # 如果未获取到窗口句柄，尝试使用 FindWindow
    if ($edgeWindow -eq 0) {
        Write-Output "警告: 无法通过 Get-Process 获取窗口句柄，尝试使用 FindWindow..."
        $edgeWindow = [WinAPI]::FindWindow("Chrome_WidgetWin_1", $null)  # Edge 的窗口类名
        if ($edgeWindow -eq 0) {
            Write-Output "错误: 无法获取Edge窗口句柄"
            return
        }
    }

    # 打印窗口句柄
    Write-Output "Edge窗口句柄: $edgeWindow"

    # 获取所有屏幕信息
    $screens = [System.Windows.Forms.Screen]::AllScreens

    # 打印屏幕数量
    Write-Output "检测到屏幕数量: $($screens.Count)"

    # 打印每个屏幕的详细信息
    for ($i = 0; $i -lt $screens.Count; $i++) {
        $screen = $screens[$i]
        Write-Output "屏幕 $i 信息:"
        Write-Output "  工作区域: $($screen.WorkingArea)"
        Write-Output "  分辨率: $($screen.Bounds.Width) x $($screen.Bounds.Height)"
    }

    # 获取目标屏幕的坐标
    if ($DisplayIndex -lt $screens.Count) {
        $targetScreen = $screens[$DisplayIndex]
        $x = $targetScreen.WorkingArea.Left
        $y = $targetScreen.WorkingArea.Top
        $width = $targetScreen.WorkingArea.Width
        $height = $targetScreen.WorkingArea.Height

        # 打印目标屏幕的坐标和大小
        Write-Output "目标屏幕 $DisplayIndex 的坐标和大小:"
        Write-Output "  X: $x, Y: $y, Width: $width, Height: $height"

        # 移动窗口
        $result = [WinAPI]::MoveWindow([IntPtr]$edgeWindow, [int]$x, [int]$y, [int]$width, [int]$height, $true)
        if ($result) {
            Write-Output "已将Edge窗口移动到屏幕 $DisplayIndex"
        } else {
            Write-Output "错误: 无法移动窗口"
        }
    } else {
        Write-Output "错误: 屏幕索引 $DisplayIndex 超出范围"
    }
}

# 在主显示器（索引0）上启动Edge
Write-Output "在主显示器上启动Edge..."
Start-EdgeOnDisplay -DisplayIndex 0

# 在扩展显示器（索引1）上启动Edge
Write-Output "在扩展显示器上启动Edge..."
Start-EdgeOnDisplay -DisplayIndex 1