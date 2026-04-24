# C1角色动画系统 - 占位符方案对比

> **目的**: 对比帧动画和骨骼动画两种占位符实现方案,选择最适合项目的技术路线
> **状态**: 实验阶段
> **创建时间**: 2026-04-24

## 方案A: 帧动画 (AnimatedSprite2D + SpriteFrames)

### 技术实现

**节点结构**:
```
C1CharacterAnimationSystem
└─ AnimatedSprite2D (角色精灵)
   └─ SpriteFrames资源 (包含所有状态的帧序列)
```

**资源组织**:
```
assets/art/characters/placeholder_frame/
├── idle_01.png           # Idle状态第1帧
├── idle_02.png           # Idle状态第2帧
├── attentive_01.png      # Attentive状态第1帧
├── attentive_02.png      # Attentive状态第2帧
├── interacting_01.png    # Interacting状态第1帧
├── interacting_02.png    # Interacting状态第2帧
├── talking_01.png        # Talking状态第1帧
├── talking_02.png        # Talking状态第2帧
├── reacting_01.png       # Reacting状态第1帧
├── performing_01.png     # Performing状态第1帧
├── away_01.png           # Away状态第1帧(透明)
├── returning_01.png      # Returning状态第1帧
└── character_frames.tres # SpriteFrames资源文件
```

**占位符图片设计**:
- 尺寸: 128×128px (2-3头身角色)
- 内容: 纯色圆形色块 + 状态文字标识
- 颜色编码:
  - IDLE: 蓝色 (#4A90E2)
  - ATTENTIVE: 绿色 (#7ED321)
  - INTERACTING: 橙色 (#F5A623)
  - TALKING: 紫色 (#BD10E0)
  - REACTING: 红色 (#D0021B)
  - PERFORMING: 黄色 (#F8E71C)
  - AWAY: 透明
  - RETURNING: 青色 (#50E3C2)

**动画设计**:
- 帧率: 8 fps (符合GDD)
- 每个状态: 2帧循环(简化版,正式版4-6帧)
- 动画效果:
  - IDLE: 上下浮动(帧1: y=0, 帧2: y=-4px)
  - ATTENTIVE: 前倾效果(帧1: 正常, 帧2: 向上偏移)
  - INTERACTING: 探出效果(帧1: 正常, 帧2: 放大1.1倍)
  - TALKING: 嘴部动画(帧1: 闭嘴, 帧2: 张嘴)
  - 其他: 静态或简单缩放

**代码实现**:
```gdscript
# 修改_setup_animation_nodes()
func _setup_animation_nodes() -> void:
    var f1_module = get_parent().get_module("f1_window_system")
    if f1_module:
        # 创建AnimatedSprite2D节点
        var animated_sprite = AnimatedSprite2D.new()
        animated_sprite.name = "CharacterSprite"
        
        # 加载SpriteFrames资源
        var frames = load("res://assets/art/characters/placeholder_frame/character_frames.tres")
        animated_sprite.sprite_frames = frames
        
        # 设置默认动画
        animated_sprite.animation = "idle"
        animated_sprite.play()
        
        f1_module.add_child(animated_sprite)
        _sprite_node = animated_sprite

# 修改_play_animation()
func _play_animation(state: AnimationState, mode: CompositionMode) -> void:
    if not _sprite_node:
        return
    
    var anim_name = AnimationState.keys()[state].to_lower()
    
    if _sprite_node.sprite_frames.has_animation(anim_name):
        _sprite_node.play(anim_name)
        print("[C1] 播放帧动画: %s" % anim_name)
    else:
        push_warning("[C1] 缺少动画: %s" % anim_name)
```

### 优点
- ✅ 符合GDD设计,无需后期重构
- ✅ 8fps帧率,符合"手绘感"目标
- ✅ 资源管理清晰,易于扩展
- ✅ 支持逐帧精细控制

### 缺点
- ❌ 需要生成16-20张图片(即使是占位符)
- ❌ 资源文件较多,管理成本稍高

### 工作量估算
- 图片生成: 30分钟(用脚本批量生成)
- SpriteFrames配置: 20分钟
- 代码适配: 15分钟
- 测试验证: 15分钟
- **总计: 约1.5小时**

---

## 方案B: 骨骼动画 (Sprite2D + AnimationPlayer)

### 技术实现

**节点结构**:
```
C1CharacterAnimationSystem
├─ Sprite2D (角色精灵)
└─ AnimationPlayer (动画播放器)
```

**资源组织**:
```
assets/art/characters/placeholder_skeleton/
├── character_base.png    # 基础角色图片(单张)
└── animations.tres       # AnimationPlayer动画资源
```

**占位符图片设计**:
- 尺寸: 128×128px
- 内容: 蓝色圆形色块 + "CHAR"文字
- 单张图片,通过代码控制变换

**动画设计**:
- 通过AnimationPlayer控制Sprite2D的属性:
  - position (位置)
  - rotation (旋转)
  - scale (缩放)
  - modulate (颜色)
- 动画效果:
  - IDLE: position.y上下浮动
  - ATTENTIVE: position.y向上偏移 + scale.y拉伸
  - INTERACTING: scale放大1.2倍
  - TALKING: rotation左右摆动
  - REACTING: scale快速放大缩小
  - 其他: 颜色变化或简单位移

**代码实现**:
```gdscript
# 修改_setup_animation_nodes()
func _setup_animation_nodes() -> void:
    var f1_module = get_parent().get_module("f1_window_system")
    if f1_module:
        # 创建Sprite2D节点
        var sprite = Sprite2D.new()
        sprite.name = "CharacterSprite"
        sprite.texture = load("res://assets/art/characters/placeholder_skeleton/character_base.png")
        sprite.centered = true
        
        f1_module.add_child(sprite)
        _sprite_node = sprite
        
        # 创建AnimationPlayer
        _animation_player = AnimationPlayer.new()
        _animation_player.name = "AnimationPlayer"
        add_child(_animation_player)
        
        # 创建动画
        _create_skeleton_animations()

func _create_skeleton_animations() -> void:
    # IDLE动画: 上下浮动
    var idle_anim = Animation.new()
    idle_anim.length = 1.0
    idle_anim.loop_mode = Animation.LOOP_LINEAR
    
    var track_idx = idle_anim.add_track(Animation.TYPE_VALUE)
    idle_anim.track_set_path(track_idx, "CharacterSprite:position:y")
    idle_anim.track_insert_key(track_idx, 0.0, 0.0)
    idle_anim.track_insert_key(track_idx, 0.5, -8.0)
    idle_anim.track_insert_key(track_idx, 1.0, 0.0)
    
    _animation_player.add_animation("idle", idle_anim)
    
    # ATTENTIVE动画: 向上偏移
    var attentive_anim = Animation.new()
    attentive_anim.length = 0.5
    attentive_anim.loop_mode = Animation.LOOP_LINEAR
    
    track_idx = attentive_anim.add_track(Animation.TYPE_VALUE)
    attentive_anim.track_set_path(track_idx, "CharacterSprite:position:y")
    attentive_anim.track_insert_key(track_idx, 0.0, 0.0)
    attentive_anim.track_insert_key(track_idx, 0.5, -12.0)
    
    _animation_player.add_animation("attentive", attentive_anim)
    
    # ... 其他状态动画类似创建

# _play_animation()保持不变,使用AnimationPlayer.play()
```

### 优点
- ✅ 只需1张图片,生成成本极低
- ✅ 快速原型验证,立即可见效果
- ✅ 动画参数可代码调整,无需重新生成图片

### 缺点
- ❌ 与GDD设计不符,后期需重构
- ❌ 无法体现"逐帧手绘感"
- ❌ 动画效果受限(只能做简单变换)
- ❌ 代码创建动画较繁琐

### 工作量估算
- 图片生成: 5分钟(单张)
- 动画代码编写: 40分钟(8个状态)
- 测试验证: 15分钟
- **总计: 约1小时**

---

## 对比总结

| 维度 | 方案A (帧动画) | 方案B (骨骼动画) |
|------|---------------|-----------------|
| **符合GDD** | ✅ 完全符合 | ❌ 不符合 |
| **后期重构** | ✅ 无需重构 | ❌ 需要重构 |
| **生成成本** | ⚠️ 中等(16-20张图) | ✅ 极低(1张图) |
| **实现时间** | ⚠️ 1.5小时 | ✅ 1小时 |
| **动画质感** | ✅ 逐帧手绘感 | ❌ 程序化变换 |
| **扩展性** | ✅ 易于添加新状态 | ⚠️ 需修改代码 |
| **调试便利** | ✅ 可视化资源 | ⚠️ 代码调试 |

## 推荐方案

**推荐方案A (帧动画)**, 理由:
1. 符合GDD设计,避免技术债务
2. 占位符简化版(2帧/状态)成本可控
3. 为后续AI生成正式资源铺平道路
4. 动画质感更接近最终目标

**方案B的适用场景**:
- 仅用于极早期原型验证(1-2天内)
- 明确后续会完全重构
- 需要快速演示给非技术人员

## 实施计划

### 阶段1: 生成方案A占位符资源
1. 编写图片生成脚本(GDScript或Python)
2. 批量生成16-20张占位符图片
3. 在Godot中配置SpriteFrames资源

### 阶段2: 适配C1代码
1. 修改`_setup_animation_nodes()`使用AnimatedSprite2D
2. 修改`_play_animation()`调用sprite_frames.play()
3. 测试所有状态切换

### 阶段3: (可选)实现方案B对比
1. 创建单张占位符图片
2. 编写AnimationPlayer动画创建代码
3. 对比两种方案的视觉效果

---

**文档状态**: 设计草案  
**下次审查**: 占位符资源生成完成后  
**负责模块**: C1角色动画系统
