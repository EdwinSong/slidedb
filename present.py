import webview
import win32api


def get_display_info():
    """
    获取所有显示器的信息。
    :return: 显示器信息列表，每个元素包含显示器的坐标和大小。
    """
    monitors = win32api.EnumDisplayMonitors()
    display_info = []
    for i, monitor in enumerate(monitors):
        monitor_info = win32api.GetMonitorInfo(monitor[0])
        monitor_rect = monitor_info["Monitor"]
        display_info.append({
            "index": i,
            "x": monitor_rect[0],
            "y": monitor_rect[1],
            "width": monitor_rect[2] - monitor_rect[0],
            "height": monitor_rect[3] - monitor_rect[1]
        })
    return display_info

def open_webview_on_display(url, title, x, y, width, height, bFullscreen=False,bFrameless=False):
    """
    在指定的显示器上打开一个 WebView 窗口。
    :param url: 要加载的 URL
    :param title: 窗口标题
    :param x: 窗口的 X 坐标
    :param y: 窗口的 Y 坐标
    :param width: 窗口宽度
    :param height: 窗口高度
    """
    # 创建 WebView 窗口
    window = webview.create_window(
        title=title,  # 窗口标题
        url=url,      # 要加载的 URL
        x=x,          # 窗口的 X 坐标
        y=y,          # 窗口的 Y 坐标
        width=width,  # 窗口宽度
        height=height, # 窗口高度
        frameless=bFrameless,
        fullscreen=bFullscreen
    )
    print(f"已创建 WebView 窗口: {title} ({url})")
    return window

def main():
    # 获取显示器信息
    displays = get_display_info()
    for display in displays:
        print(f"显示器 {display['index']}: X={display['x']}, Y={display['y']}, "
              f"Width={display['width']}, Height={display['height']}")

    # 检查是否有至少两个显示器
    if len(displays) < 2:
        print("错误: 需要至少两个显示器")
        return

    # 在主显示器（索引0）上打开第一个 WebView 窗口
    print("在主显示器上打开 WebView 窗口...")
    window = open_webview_on_display(
        url="http://localhost:3030/presenter/",
        title="Presenter",
        x=displays[0]["x"],
        y=displays[0]["y"],
        width=displays[0]["width"],
        height=displays[0]["height"],
    )

    # 在扩展显示器（索引1）上打开第二个 WebView 窗口
    print("在扩展显示器上打开 WebView 窗口...")
    fullscreen_window = open_webview_on_display(
        url="http://localhost:3030/",
        title="Slide",
        x=displays[1]["x"],
        y=displays[1]["y"],
        width=displays[1]["width"],
        height=displays[1]["height"],
        bFrameless=False,
        bFullscreen=True
    )

    def on_closed():
    # 当普通窗口关闭时，关闭全屏窗口
        if fullscreen_window:
            fullscreen_window.destroy()
        print("所有窗口已关闭")

    window.events.closed += on_closed 

    # 启动 WebView 事件循环
    webview.start()

if __name__ == "__main__":
    main()