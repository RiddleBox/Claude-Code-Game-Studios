# F1 Desktop Window System — 桌面模式测试指南

## 问题诊断
根据测试结果，Godot在**编辑器嵌入式窗口**中运行，导致以下限制：
- ❌ "Embedded window can't become on top." (无法置顶)
- ❌ "Embedded window can't be moved." (无法移动)  
- ❌ 窗口有边框，不是无边框
- ❌ 背景黑色，不是透明

## 解决方案
使用以下三种方法之一进行**桌面模式测试**：

---

## 方法一：导出项目 (推荐)

### 步骤1：配置导出预设
1. 在Godot编辑器中，点击顶部菜单：**项目 → 导出...**
2. 点击"添加..." → 选择"Windows Desktop"
3. 配置导出预设：
   - **导出路径**: `d:\AIProjects\Claude-Code-Game-Studios\bin\window-whisper.exe`
   - **架构**: x86_64 (64位)
   - **功能**: 保持默认

### 步骤2：导出项目
1. 点击"导出项目"
2. 选择保存位置，确认导出

### 步骤3：运行导出程序
1. 打开文件管理器
2. 导航到 `d:\AIProjects\Claude-Code-Game-Studios\bin\`
3. 双击 `window-whisper.exe`

### 预期结果
- ✅ 透明无边框窗口
- ✅ 窗口始终置顶
- ✅ 可拖拽移动
- ✅ 控制台输出显示桌面模式

---

## 方法二：命令行运行

### 步骤1：打开命令行
1. 按 `Win + R` 输入 `cmd` 回车
2. 或使用PowerShell

### 步骤2：运行Godot项目
```cmd
cd /d "D:\3_Tool\Godot_v4.6.1-stable"
Godot_v4.6.1-stable.exe --path "d:\AIProjects\Claude-Code-Game-Studios"
```

### 步骤3：验证运行模式
- 观察控制台输出，应该显示 `[F1] Initializing in DESKTOP mode`

### 预期结果
- ✅ 独立窗口运行，非嵌入式
- ✅ 完整桌面窗口功能

---

## 方法三：更改编辑器运行设置 (临时方案)

### 步骤1：编辑器设置
1. 在Godot编辑器中，点击顶部菜单：**编辑器 → 编辑器设置**
2. 搜索 "运行"
3. 找到 **运行/输出 → 运行模式**
4. 更改为 **"在分离窗口中"** (Separate Window)

### 步骤2：重新运行
1. 按F5运行项目
2. 应该打开独立窗口

### 注意事项
- 此设置仅影响编辑器内测试
- 每次启动编辑器可能需要重新配置

---

## 验证成功标准

### 控制台输出（桌面模式）
```
[F1] F1 Window System initializing...
[F1] Initializing in DESKTOP mode (standalone application)
[F1] Window flags set: transparent, always-on-top, borderless
[F1] Viewport transparent background enabled
[F1] Windows platform detected. GDExtension integration pending.
[F1] Click-through temporarily disabled for initial testing
[F1] Drag handling initialized. Character sprite: CharacterSprite
[F1] Desktop mode initialization complete
```

### 窗口表现
- [ ] 窗口透明（看到桌面背景）
- [ ] 窗口无边框（无标题栏、无按钮）
- [ ] 窗口始终置顶（在其他应用之上）
- [ ] 可拖拽移动（点击蓝色图标拖动）
- [ ] 尺寸固定300×400

---

## 故障排除

### 问题1：仍然有边框/不透明
**可能原因**: project.godot设置未生效
**解决方案**:
1. 检查 `project.godot` 文件是否被修改
2. 确保以下设置存在：
   ```ini
   window/size/borderless=true
   window/size/always_on_top=true
   window/size/transparent=true
   viewport/transparent_background=true
   ```

### 问题2：窗口位置异常
**可能原因**: 多显示器坐标问题
**解决方案**:
1. 代码已处理Vector2i/Vector2转换
2. 位置应在屏幕右下角

### 问题3：无法拖拽
**可能原因**: 点击区域判定问题
**解决方案**:
1. 确保点击蓝色图标区域
2. 检查控制台是否有 `[F1] Drag started` 消息

---

## 下一步测试
F1基础功能验证成功后：
1. 运行 `/gate-check` 更新状态
2. 开始实现 F2 Character State Machine
3. 继续Sprint 1计划

---

## 快速检查清单
- [ ] 使用桌面模式运行（非编辑器嵌入式）
- [ ] 控制台显示"DESKTOP mode"
- [ ] 窗口透明无边框
- [ ] 拖拽功能正常
- [ ] 无"Embedded window"错误消息