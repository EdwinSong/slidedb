import subprocess
import time
import win32api
import win32con
import win32gui

def move_window_to_display(hwnd, display_index):
    """
    将窗口移动到指定的显示器，并最大化窗口。
    :param hwnd: 窗口句柄
    :param display_index: 显示器索引（0 表示主显示器，1 表示扩展显示器）
    """
    # 获取所有显示器的信息
    monitors = win32api.EnumDisplayMonitors()
    if display_index >= len(monitors):
        print(f"错误: 显示器索引 {display_index} 超出范围")
        return

    # 获取目标显示器的坐标和大小
    monitor_info = win32api.GetMonitorInfo(monitors[display_index][0])
    monitor_rect = monitor_info["Monitor"]
    work_rect = monitor_info["Work"]  # 工作区域（排除任务栏）

    x = work_rect[0]
    y = work_rect[1]
    width = work_rect[2] - work_rect[0]
    height = work_rect[3] - work_rect[1]

    # 打印目标显示器的坐标和大小
    print(f"目标显示器 {display_index} 的坐标和大小:")
    print(f"  X: {x}, Y: {y}, Width: {width}, Height: {height}")

    # 移动窗口到目标显示器
    win32gui.MoveWindow(hwnd, x, y, width, height, True)
    print(f"已将窗口移动到显示器 {display_index}")

    # 最大化窗口
    win32gui.ShowWindow(hwnd, win32con.SW_MAXIMIZE)
    print(f"已将窗口最大化")

def start_edge_on_display(display_index):
    """
    启动 Edge 并移动到指定的显示器。
    :param display_index: 显示器索引（0 表示主显示器，1 表示扩展显示器）
    """
    # Edge 的完整路径
    edge_path = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

    # 启动 Edge 浏览器
    try:
        edge_process = subprocess.Popen([edge_path])
    except FileNotFoundError:
        print(f"错误: 未找到 Edge 可执行文件。请确保 Edge 已安装，路径为: {edge_path}")
        return

    # 等待 Edge 窗口加载完成
    time.sleep(10)  # 增加等待时间

    # 获取 Edge 窗口句柄
    hwnd = None
    def enum_windows_callback(hwnd_current, _):
        nonlocal hwnd
        # 通过窗口类名查找 Edge 窗口
        class_name = win32gui.GetClassName(hwnd_current)
        if class_name == "Chrome_WidgetWin_1":
            hwnd = hwnd_current
            return False  # 停止枚举
        return True  # 继续枚举

    # 枚举所有窗口
    win32gui.EnumWindows(enum_windows_callback, None)

    if hwnd is None:
        print("错误: 无法获取 Edge 窗口句柄")
        return

    # 打印窗口的标题和类名
    window_title = win32gui.GetWindowText(hwnd)
    window_class = win32gui.GetClassName(hwnd)
    print(f"找到 Edge 窗口:")
    print(f"  标题: {window_title}")
    print(f"  类名: {window_class}")

    # 将窗口移动到目标显示器并最大化
    move_window_to_display(hwnd, display_index)

# 在主显示器（索引0）上启动 Edge
print("在主显示器上启动 Edge...")
start_edge_on_display(0)

# 在扩展显示器（索引1）上启动 Edge
print("在扩展显示器上启动 Edge...")
start_edge_on_display(1)