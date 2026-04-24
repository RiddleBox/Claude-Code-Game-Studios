# 背景分层系统设计

## 问题陈述

当前背景实现（单张平面图片）存在以下问题：
- 缺乏景深和空间层次感
- 视觉效果廉价，缺少沉浸感
- 无法体现"透过窗口观察异世界"的核心体验

## 设计目标

通过多层图片叠加，构建具有真实景深的背景系统，让玩家感受到：
1. 明确的空间距离感（从远景到窗框）
2. 丰富的视觉层次
3. "透过窗口窥视另一个世界"的沉浸体验

## 分层结构设计

### 层级定义（从远到近）

```
Layer 1: 远景层 (Distant Background)
  ├─ 内容：天空、远处城市轮廓、山脉、云层
  ├─ 距离：最远（窗外数公里）
  ├─ 视差：最慢（0.1x）
  └─ 模糊度：轻微景深模糊

Layer 2: 中景层 (Mid Background)
  ├─ 内容：窗外可见的建筑、街道、邻近建筑
  ├─ 距离：中等（窗外数十米到数百米）
  ├─ 视差：中等（0.3x）
  └─ 模糊度：清晰

Layer 3: 房屋结构层 (Room Structure)
  ├─ 内容：墙壁、窗框外侧、阳台栏杆
  ├─ 距离：窗口所在平面
  ├─ 视差：标准（1.0x）
  └─ 模糊度：完全清晰

Layer 4: 室内摆设层 (Room Furnishing)
  ├─ 内容：桌椅、书架、地板、装饰物
  ├─ 距离：窗内1-3米
  ├─ 视差：较快（1.5x）
  └─ 模糊度：完全清晰

Layer 5: 窗口衔接层 (Window Frame)
  ├─ 内容：窗框内侧、窗台、窗帘边缘
  ├─ 距离：最近（窗口边缘）
  ├─ 视差：最快（2.0x）
  └─ 模糊度：完全清晰
  └─ 作用：体现"玩家视角位置"，增强窥视感

Layer 6: 角色层 (Character)
  ├─ 内容：角色精灵（已有）
  ├─ 距离：窗内1-2米
  └─ 视差：标准（1.0x）
```

### 层级距离一致性原则

**关键约束**：每一层内的所有元素必须在空间距离上保持一致

- **远景层**：所有元素都在"窗外远处"（天空、远山、远处建筑）
- **中景层**：所有元素都在"窗外中距离"（邻近建筑、街道）
- **室内层**：所有元素都在"窗内同一深度"（同一房间内的家具）
- **窗框层**：所有元素都在"窗口边缘"（窗框、窗台）

**反例**：不要在同一层混合"远处天空"和"近处桌子"

## 视觉效果增强

### 1. 视差滚动（Parallax Scrolling）
- 当角色在房间内移动时，不同层以不同速度移动
- 远景移动最慢，近景移动最快
- 增强空间深度感

### 2. 景深模糊（Depth of Field）
- 远景层：轻微高斯模糊（blur_amount = 1.5）
- 中景层：清晰
- 近景层：清晰
- 可选：焦点外的层轻微模糊

### 3. 大气透视（Atmospheric Perspective）
- 远景层：降低饱和度10-15%，增加蓝色调
- 中景层：正常色彩
- 近景层：正常色彩

### 4. 光照一致性
- 所有层的光源方向必须一致
- 时间系统变化时，所有层同步调整色温和亮度

## 技术实现方案

### Godot节点结构

```
F1WindowSystem (SubViewport 320x320)
├─ BackgroundContainer (Control)
│  ├─ Layer1_Distant (TextureRect, z_index=-50)
│  ├─ Layer2_Mid (TextureRect, z_index=-40)
│  ├─ Layer3_Structure (TextureRect, z_index=-30)
│  ├─ Layer4_Furnishing (TextureRect, z_index=-20)
│  └─ Layer5_WindowFrame (TextureRect, z_index=-10)
└─ CharacterSprite (Sprite2D, z_index=0)
```

### 资产命名规范

```
assets/art/backgrounds/theme_XX/
├─ layer1_distant.png          # 远景层
├─ layer2_mid.png               # 中景层
├─ layer3_structure.png         # 房屋结构层
├─ layer4_furnishing.png        # 室内摆设层
└─ layer5_window_frame.png      # 窗口衔接层
```

### 代码接口设计

```gdscript
# F1WindowSystem新增方法

## 加载分层背景主题
func load_layered_background(theme_id: String) -> bool:
    # 加载主题的所有层级图片
    # 创建对应的TextureRect节点
    # 设置z_index和视差参数
    pass

## 设置背景状态（外出态/正常态）
func set_background_state(state: BackgroundState) -> void:
    # 同时调整所有层的modulate
    pass

## 启用/禁用视差效果
func set_parallax_enabled(enabled: bool) -> void:
    pass

## 设置景深模糊强度
func set_depth_blur(layer: int, blur_amount: float) -> void:
    pass
```

## 美术生产流程调整

### 1. 场景设计阶段
- 明确定义每一层的内容清单
- 确保层级距离逻辑一致
- 绘制分层示意图

### 2. AI生成阶段
- **方案A**：分层生成（推荐）
  - 分别生成每一层的内容
  - 提示词中明确指定"透明背景"和"该层专属内容"
  - 优点：精确控制，易于调整
  - 缺点：需要多次生成

- **方案B**：整图生成后分层
  - 生成完整场景图
  - 使用Photoshop/GIMP手动分层
  - 优点：整体一致性好
  - 缺点：手动工作量大

### 3. 后期处理
- 为远景层添加轻微模糊
- 调整各层色彩一致性
- 确保透明区域正确

## 当前状态与优先级

### 当前实现
- ✅ 单层背景图片加载
- ✅ 背景状态切换（外出态变暗）
- ❌ 分层系统
- ❌ 视差效果
- ❌ 景深模糊

### 下一轮F1迭代优先级
**🔴 高优先级**：实现分层背景系统
1. 重构F1背景加载逻辑，支持多层加载
2. 实现基础分层显示（无视差，无模糊）
3. 更新主题01为分层版本（至少3层：远景/室内/窗框）
4. 测试分层效果是否解决"廉价感"问题

**🟡 中优先级**：视觉效果增强
5. 实现视差滚动效果
6. 添加景深模糊shader
7. 实现大气透视效果

**🟢 低优先级**：高级特性
8. 动态光照调整
9. 天气效果叠加层
10. 交互式前景元素

## 参考案例

### 游戏参考
- **Unpacking**：精致的分层室内场景
- **A Short Hike**：清晰的景深层次
- **Spiritfarer**：多层视差背景

### 技术参考
- Godot ParallaxBackground节点
- Godot BackBufferCopy + Shader实现景深模糊
- 2D分层场景最佳实践

## 相关文档

- [场景内容框架](./scene-content-framework.md) - 需要更新，增加分层设计章节
- [场景生成工作流](./scene-generation-workflow.md) - 需要更新，增加分层生成流程
- [主题01设计](./scene-theme-library/theme-01-modern-fantasy-rooftop.md) - 需要重新设计为分层版本

---

**文档状态**：设计草案  
**创建时间**：2026-04-22  
**下次审查**：F1窗口系统下一轮迭代前  
**负责模块**：F1窗口系统
