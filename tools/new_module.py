#!/usr/bin/env python3
"""
new_module.py — IModule 骨架生成器

用法:
    python tools/new_module.py <module_id> <ClassName> [category] [priority]

示例:
    python tools/new_module.py f5_audio_system F5AudioSystem core high
    python tools/new_module.py c1_character_animation C1CharacterAnimation gameplay medium

生成路径:
    src/core/<module_id>/<module_id>.gd       (category=core)
    src/gameplay/<module_id>/<module_id>.gd   (category=gameplay)
    src/ui/<module_id>/<module_id>.gd         (category=ui)

注意: 生成的文件使用 Tab 缩进、LF 行尾、UTF-8 编码，与 patch_gd.py 保持一致。
"""

import sys
import os
import argparse

TEMPLATE = """\
# {category}/{module_id}/{module_id}.gd
# {class_name} — TODO: 填写模块描述
# 实现 IModule 接口，支持模块化架构

class_name {class_name}
extends Node

## IModule 接口实现
var module_id: String = "{module_id}"
var module_name: String = "{module_id}"  # TODO: 改为中文名
var module_version: String = "1.0.0"
var dependencies: Array[String] = []  # TODO: 填写依赖模块 ID
var optional_dependencies: Array[String] = []
var config_path: String = "res://data/config/{module_id}.json"
var category: String = "{category}"
var priority: String = "{priority}"
var status: IModule.ModuleStatus = IModule.ModuleStatus.UNINITIALIZED
var last_error: Dictionary = {{}}

## ==================== 系统常量 ====================

# TODO: 在这里声明 const 常量（无缩进，类体级）

## ==================== 信号 ====================

# TODO: 在这里声明 signal（无缩进，类体级）
# 示例: signal some_event(data: Dictionary)

## ==================== 私有变量 ====================

# TODO: 在这里声明私有变量（无缩进，类体级，用 _ 前缀）

## ==================== IModule 接口方法 ====================

## IModule.initialize() 实现
func initialize(_config: Dictionary = {{}}) -> bool:
\tprint("[{tag}] 初始化 {module_id}...")
\tstatus = IModule.ModuleStatus.INITIALIZING

\t# TODO: 实现初始化逻辑

\tstatus = IModule.ModuleStatus.INITIALIZED
\tprint("[{tag}] {module_id} 初始化完成")
\treturn true

## IModule.start() 实现
func start() -> bool:
\tprint("[{tag}] 启动 {module_id}...")
\tstatus = IModule.ModuleStatus.STARTING

\t# TODO: 实现启动逻辑

\tstatus = IModule.ModuleStatus.RUNNING
\tprint("[{tag}] {module_id} 启动完成")
\treturn true

## IModule.stop() 实现
func stop() -> void:
\tprint("[{tag}] 停止 {module_id}...")
\tstatus = IModule.ModuleStatus.STOPPING

\t# TODO: 实现停止逻辑（释放资源、保存状态等）

\tstatus = IModule.ModuleStatus.STOPPED
\tprint("[{tag}] {module_id} 已停止")

## IModule.get_module_info() 实现
func get_module_info() -> Dictionary:
\treturn {{
\t\t"id": module_id,
\t\t"name": module_name,
\t\t"version": module_version,
\t\t"category": category,
\t\t"priority": priority,
\t\t"status": status,
\t\t"dependencies": dependencies,
\t\t"optional_dependencies": optional_dependencies,
\t}}

## IModule.is_healthy() 实现
func is_healthy() -> bool:
\treturn status == IModule.ModuleStatus.RUNNING

## IModule.get_last_error() 实现
func get_last_error() -> Dictionary:
\treturn last_error

## ==================== 私有方法 ====================

# TODO: 在这里实现私有方法
"""

CATEGORY_PATHS = {
    "core": "src/core",
    "gameplay": "src/gameplay",
    "ui": "src/ui",
    "audio": "src/audio",
}


def main():
    parser = argparse.ArgumentParser(description="生成 IModule 骨架文件")
    parser.add_argument("module_id", help="模块 ID，如 f5_audio_system")
    parser.add_argument("class_name", help="类名（PascalCase），如 F5AudioSystem")
    parser.add_argument("category", nargs="?", default="core",
                        help="模块分类：core / gameplay / ui / audio（默认 core）")
    parser.add_argument("priority", nargs="?", default="medium",
                        help="优先级：high / medium / low（默认 medium）")
    args = parser.parse_args()

    base_dir = CATEGORY_PATHS.get(args.category, f"src/{args.category}")
    out_dir = os.path.join(base_dir, args.module_id)
    out_file = os.path.join(out_dir, f"{args.module_id}.gd")

    if os.path.exists(out_file):
        print(f"[ERROR] 文件已存在: {out_file}")
        print("如果要覆盖，请手动删除后重试。")
        sys.exit(1)

    os.makedirs(out_dir, exist_ok=True)

    # tag = 模块 ID 的大写前缀，如 f5_audio_system → F5
    tag = args.module_id.split("_")[0].upper()

    content = TEMPLATE.format(
        module_id=args.module_id,
        class_name=args.class_name,
        category=args.category,
        priority=args.priority,
        tag=tag,
    )

    # 强制 UTF-8 + LF（与 patch_gd.py 一致）
    with open(out_file, "w", encoding="utf-8", newline="\n") as f:
        f.write(content)

    print(f"[OK] 已生成: {out_file}")
    print(f"[OK] 下一步：在 src/app/app.gd 中添加 _register_{args.module_id}() 调用")


if __name__ == "__main__":
    main()
