# ADR-001: F1 桌面窗口系统实现方案 (Desktop Window System Implementation)

## 状态 (Status)

**Accepted** (已接受)

## 背景 (Context)

《窗语》的核心体验在于“陪伴不打扰”。角色立绘悬浮在用户桌面上，要求角色透明部分必须实现“像素级点击穿透”，以确保用户在点击立绘边缘或空隙处的桌面图标时，不会被不可见的窗口边界阻挡。同时，角色身体部分必须能够响应拖拽、抚摸等交互。

## 决策 (Decision)

采用 **方案 C: 混合模式 (Hybrid Hook)**。

1.  **渲染层**: 利用 Godot 4 的 `DisplayServer` 开启 `transparent_background` 和 `always_on_top`。
2.  **交互层**: 通过 GDExtension (C++) 拦截 Windows 原生消息 `WM_NCHITTEST`。
3.  **判定逻辑**: 当鼠标在窗口范围内移动时，系统截获 `WM_NCHITTEST` 消息。GDExtension 查询当前位置对应 Alpha 贴图的像素值：
    - 若 `Alpha < Threshold` (如 0.1)，返回 `HTTRANSPARENT`，使消息穿透到下层窗口。
    - 若 `Alpha >= Threshold`，返回 `HTCLIENT`，由 Godot 响应正常交互。

## 理由 (Consequences)

- **性能**: 消息拦截在系统底层完成，耗时极低 (<0.1ms)，避免了 Godot 每帧计算复杂多边形区域的 CPU 开销。
- **精度**: 支持像素级判定，完美解决“空气墙”问题。
- **稳定性**: 仅拦截点击判定消息，不强行接管渲染管线，风险远低于方案 B。
- **限制**: 初始实现仅支持 Windows 11/10。跨平台（macOS/Linux）需在未来通过平台特定的 API 分别实现。

## 接口定义 (Interface)

```gdscript
# F1_WindowSystem (GDExtension Node)
func set_passthrough_enabled(enabled: bool) -> void
func set_alpha_threshold(threshold: float) -> void
func update_hit_map(texture: Texture2D) -> void
```