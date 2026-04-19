# Assets Directory Structure

游戏资产组织结构和规范说明。

## 目录结构

```
assets/
├── art/              # 美术资产
│   ├── characters/   # 角色精灵、动画
│   ├── ui/           # UI元素、界面
│   ├── environments/ # 环境、背景
│   ├── icons/        # 图标、小图
│   └── effects/      # 2D特效、粒子
├── audio/            # 音频资产
│   ├── music/        # 背景音乐
│   ├── sfx/          # 音效
│   ├── voice/        # 语音
│   └── ambient/      # 环境音
├── vfx/              # 视觉特效（粒子系统、着色器特效）
├── shaders/          # 自定义着色器
└── data/             # 数据文件（配置、本地化）
```

## 状态

**当前阶段**: Pre-Production → Vertical Slice 过渡期

### 待完成工作

1. **建立Art Bible** (`design/art/art-bible.md`)
   - 视觉风格定义
   - 色彩方案
   - 角色/UI/环境美术标准
   - 资产规格和命名规范

2. **为22个模块创建素材样例**
   - 优先级P0: F1窗口、C1角色、P1主UI
   - 优先级P1: C2外出归来、P2/P3 UI、Fe5音频
   - 优先级P2: 其余15个模块

3. **建立资产工作流**
   - AI生成工具集成
   - 资产导入/处理流程
   - 版本管理

## 命名规范

**待Art Bible确立后填写**

临时规范（参考`technical-preferences.md`）：
- 文件名: `snake_case`
- 格式: `[category]_[name]_[variant].[ext]`
- 示例: `character_aria_idle.png`, `ui_button_primary.png`

## 资产规格

**待Art Bible确立后填写**

临时目标：
- 角色精灵: 待定
- UI元素: 待定
- 音频: 待定

## 工作流程

**待建立**

计划流程：
1. AI生成 → 2. 格式转换 → 3. 导入Godot → 4. 配置资源 → 5. 集成测试

## 相关文档

- Art Bible: `design/art/art-bible.md` (待创建)
- Sound Bible: `design/audio/sound-bible.md` (待创建)
- Asset Audit: 运行 `/asset-audit` 检查资产合规性
- Technical Preferences: `.claude/docs/technical-preferences.md`

## 下一步行动

1. 运行 `art-director` 代理创建Art Bible
2. 确定核心模块（F1/C1/P1）的素材规格
3. 创建第一批素材样例
4. 验证素材在Godot中正确显示
5. 建立AI生成工作流
