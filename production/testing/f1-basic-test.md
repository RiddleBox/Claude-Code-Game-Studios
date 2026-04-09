# F1 桌面窗口系统 - 基础功能测试指南

**测试日期**: 2026-04-08  
**测试版本**: Sprint 1 基础实现 (无 GDExtension)  
**测试目标**: 验证窗口透明度、置顶、拖拽等基本功能

## 测试环境要求
- Godot 4.6.1 (`D:\3_Tool\Godot_v4.6.1-stable`)
- Windows 10/11 操作系统
- 显示器分辨率至少 1024×768

## 测试步骤

### 1. 启动项目
1. 打开 Godot 4.6.1
2. 选择"导入项目"
3. 选择 `d:\AIProjects\Claude-Code-Game-Studios\` 目录
4. 点击"导入并编辑"
5. 点击运行按钮 (或按 F5)

### 2. 预期初始状态
- 窗口出现在屏幕**右下角** (距边缘约24px)
- 窗口尺寸: 300×400 像素 (配置在 project.godot)
- 窗口**无边框** (borderless)
- 窗口**始终置顶** (always on top)
- 窗口**背景透明**，仅显示角色图标 (icon.svg)
- 控制台输出应显示:
  ```
  [F1] Windows platform detected. GDExtension integration pending.
  [F1] Fallback click passthrough configured
  [F1] Drag handling initialized. Character sprite: CharacterSprite
  ```

### 3. 功能测试清单

#### ✅ 窗口外观测试
- [ ] **透明度**: 窗口背景透明，可以看到桌面背景透过
- [ ] **置顶行为**: 打开其他应用 (如浏览器、文件管理器)，F1 窗口应保持在最上层
- [ ] **无边框**: 窗口没有标题栏、边框、关闭按钮
- [ ] **尺寸固定**: 窗口不能调整大小 (resizable=false)

#### ✅ 交互测试
- [ ] **拖拽功能**: 点击角色图标 (icon.svg) 并拖动，窗口应跟随鼠标移动
- [ ] **拖拽释放**: 释放鼠标后，窗口停留在新位置
- [ ] **点击穿透 (fallback)**: 点击角色图标**以外**的透明区域，点击应**穿透**到下层窗口 (如桌面图标或应用)

#### ✅ 控制台输出验证
- [ ] 启动时显示正确的平台检测信息
- [ ] 拖拽开始时/结束时有日志输出 (需要添加)

### 4. 问题排查

#### 常见问题
1. **窗口不透明/有黑背景**
   - 检查 `project.godot` 中 `window/per_pixel_transparency/allowed=true`
   - 检查 `viewport/transparent_background=true`

2. **窗口不置顶**
   - 检查 `project.godot` 中 `window/size/always_on_top=true`
   - 某些桌面环境可能限制置顶行为

3. **拖拽不工作**
   - 检查控制台是否有错误信息
   - 确保点击的是角色图标区域
   - 检查 `f1_window_system.gd` 中的 `_input` 函数

4. **点击穿透不工作**
   - Fallback 模式仅角色矩形区域可交互
   - 透明区域应穿透到下层
   - 如果完全不穿透，可能是 `DisplayServer.window_set_mouse_passthrough()` API 问题

### 5. 测试记录模板

```markdown
## 测试记录 - [日期] [时间]

### 环境
- Godot 版本: [ ]
- 操作系统: [ ]
- 显示器: [ ]

### 测试结果
1. 窗口透明度: [通过/失败] 备注: [ ]
2. 窗口置顶: [通过/失败] 备注: [ ]
3. 窗口无边框: [通过/失败] 备注: [ ]
4. 拖拽功能: [通过/失败] 备注: [ ]
5. 点击穿透: [通过/失败] 备注: [ ]

### 控制台输出
```
[粘贴相关控制台输出]
```

### 发现问题
- [问题1描述]
- [问题2描述]

### 建议
- [改进建议]
```

### 6. 后续步骤
通过基础测试后，下一步将:
1. 修复发现的任何问题
2. 实现 GDExtension 像素级点击穿透
3. 添加系统托盘功能
4. 集成 F2 角色状态机

## 技术说明
当前实现使用 **回退模式 (fallback mode)**:
- 点击穿透: 使用 `DisplayServer.window_set_mouse_passthrough()` 多边形蒙版
- 仅角色矩形区域可交互，其他区域穿透
- 未来将通过 GDExtension 升级为像素级精确判定