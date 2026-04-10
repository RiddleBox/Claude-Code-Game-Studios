#!/usr/bin/env python3
"""
patch_gd.py — GDScript 文件行级修改工具
用于替代 Edit 工具失败时的 sed/awk/Bash 方案

用法:
  # 替换单行
  python patch_gd.py <file> <line_num> "<new_content>"

  # 替换多行（传入 JSON 格式的行号:内容映射）
  python patch_gd.py <file> --multi '{"125": "\\t\\tvar x = 1", "126": "\\t\\tif x:"}'

  # 删除行
  python patch_gd.py <file> --delete <line_num>

  # 删除多行范围
  python patch_gd.py <file> --delete-range <start> <end>

  # 在某行之后插入新行
  python patch_gd.py <file> --insert-after <line_num> "<new_content>"

  # 查看行内容（调试用，显示 repr 以确认 Tab/空格）
  python patch_gd.py <file> --inspect <start> <end>

行号从 1 开始（和编辑器一致）。
所有写入强制使用 UTF-8 + LF（Godot 要求）。
"""

import sys
import json
import argparse
import os


def read_file(path: str) -> list[str]:
    """读取文件，返回行列表（保留换行符）"""
    with open(path, "r", encoding="utf-8") as f:
        return f.readlines()


def write_file(path: str, lines: list[str]) -> None:
    """写回文件，强制 UTF-8 + LF"""
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.writelines(lines)


def ensure_newline(content: str) -> str:
    """确保内容以 \\n 结尾"""
    if not content.endswith("\n"):
        return content + "\n"
    return content


def inspect_lines(lines: list[str], start: int, end: int) -> None:
    """打印行内容（repr 格式，显示 Tab/空格/换行符）"""
    total = len(lines)
    start = max(1, start)
    end = min(total, end)
    print(f"=== 文件共 {total} 行，显示 {start}-{end} ===")
    for i in range(start - 1, end):
        print(f"{i+1:04d}: {repr(lines[i])}")


def replace_line(lines: list[str], line_num: int, new_content: str) -> list[str]:
    """替换指定行"""
    idx = line_num - 1
    if idx < 0 or idx >= len(lines):
        raise ValueError(f"行号 {line_num} 超出范围（文件共 {len(lines)} 行）")
    print(f"替换前 {line_num:04d}: {repr(lines[idx])}")
    lines[idx] = ensure_newline(new_content)
    print(f"替换后 {line_num:04d}: {repr(lines[idx])}")
    return lines


def replace_multi(lines: list[str], mapping: dict[str, str]) -> list[str]:
    """批量替换多行，mapping = {行号字符串: 新内容}"""
    for line_num_str, new_content in mapping.items():
        lines = replace_line(lines, int(line_num_str), new_content)
    return lines


def delete_line(lines: list[str], line_num: int) -> list[str]:
    """删除指定行"""
    idx = line_num - 1
    if idx < 0 or idx >= len(lines):
        raise ValueError(f"行号 {line_num} 超出范围（文件共 {len(lines)} 行）")
    print(f"删除 {line_num:04d}: {repr(lines[idx])}")
    del lines[idx]
    return lines


def delete_range(lines: list[str], start: int, end: int) -> list[str]:
    """删除 start 到 end 范围内的行（含两端，行号从 1 开始）"""
    if start > end:
        raise ValueError(f"start({start}) > end({end})")
    print(f"删除行范围 {start}-{end}（共 {end - start + 1} 行）")
    for i in range(start - 1, end):
        print(f"  {i+1:04d}: {repr(lines[i])}")
    del lines[start - 1:end]
    return lines


def insert_after(lines: list[str], line_num: int, new_content: str) -> list[str]:
    """在 line_num 行之后插入新行"""
    idx = line_num  # insert at idx means after line_num (0-based)
    if line_num < 0 or line_num > len(lines):
        raise ValueError(f"行号 {line_num} 超出范围（文件共 {len(lines)} 行）")
    new_line = ensure_newline(new_content)
    lines.insert(idx, new_line)
    print(f"在第 {line_num} 行后插入: {repr(new_line)}")
    return lines


def run_godot_verify(project_path: str) -> bool:
    """运行 Godot headless 验证，返回是否通过"""
    godot_exe = r"D:\3_Tool\Godot_v4.6.1-stable\Godot_v4.6.1-stable_win64.exe"
    if not os.path.exists(godot_exe):
        print("⚠️  Godot 可执行文件不存在，跳过验证")
        return True  # 无法验证，不阻塞

    import subprocess
    print(f"\n🔍 运行 Godot headless 验证...")

    # import
    subprocess.run(
        [godot_exe, "--path", project_path, "--headless", "--import"],
        capture_output=True, timeout=60
    )

    # verify
    result = subprocess.run(
        [godot_exe, "--path", project_path, "--headless", "--quit"],
        capture_output=True, text=True, timeout=60
    )

    output = result.stderr or result.stdout
    errors = [l for l in output.splitlines() if l.startswith(("ERROR", "SCRIPT ERROR"))]

    if errors:
        print("❌ 验证失败:")
        for e in errors:
            print(f"   {e}")
        return False
    else:
        print("✅ 验证通过（0 SCRIPT ERROR）")
        return True


def main():
    parser = argparse.ArgumentParser(
        description="GDScript 文件行级修改工具（patch_gd.py）",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    parser.add_argument("file", help="目标 .gd 文件路径")
    parser.add_argument("line_num", nargs="?", type=int, help="行号（从 1 开始）")
    parser.add_argument("new_content", nargs="?", help="新行内容（Tab 用 \\t 表示）")

    parser.add_argument("--multi", help="批量替换，JSON 格式 '{\"行号\": \"内容\"}'")
    parser.add_argument("--delete", type=int, metavar="LINE", help="删除指定行")
    parser.add_argument("--delete-range", type=int, nargs=2, metavar=("START", "END"),
                        help="删除行范围（含两端）")
    parser.add_argument("--insert-after", type=int, metavar="LINE",
                        help="在指定行后插入新行（配合 new_content 使用）")
    parser.add_argument("--inspect", type=int, nargs=2, metavar=("START", "END"),
                        help="查看行内容（repr 格式，不修改文件）")
    parser.add_argument("--no-verify", action="store_true",
                        help="跳过 Godot headless 验证")
    parser.add_argument("--project", default=r"D:\AIproject\claude-code-game-studios",
                        help="Godot 项目路径（用于验证，默认 CGS 项目）")

    args = parser.parse_args()

    if not os.path.exists(args.file):
        print(f"❌ 文件不存在: {args.file}")
        sys.exit(1)

    lines = read_file(args.file)
    modified = False

    # --inspect：只读，不修改
    if args.inspect:
        inspect_lines(lines, args.inspect[0], args.inspect[1])
        return

    # --delete
    if args.delete is not None:
        lines = delete_line(lines, args.delete)
        modified = True

    # --delete-range
    elif args.delete_range is not None:
        lines = delete_range(lines, args.delete_range[0], args.delete_range[1])
        modified = True

    # --insert-after
    elif args.insert_after is not None:
        if not args.new_content:
            print("❌ --insert-after 需要同时提供 new_content 参数")
            sys.exit(1)
        content = args.new_content.replace("\\t", "\t").replace("\\n", "\n")
        lines = insert_after(lines, args.insert_after, content)
        modified = True

    # --multi
    elif args.multi is not None:
        try:
            mapping = json.loads(args.multi)
        except json.JSONDecodeError as e:
            print(f"❌ --multi JSON 解析失败: {e}")
            sys.exit(1)
        # 处理转义
        mapping = {k: v.replace("\\t", "\t").replace("\\n", "\n") for k, v in mapping.items()}
        lines = replace_multi(lines, mapping)
        modified = True

    # 单行替换（默认模式）
    elif args.line_num is not None and args.new_content is not None:
        content = args.new_content.replace("\\t", "\t").replace("\\n", "\n")
        lines = replace_line(lines, args.line_num, content)
        modified = True

    else:
        parser.print_help()
        sys.exit(0)

    if modified:
        write_file(args.file, lines)
        print(f"\n✅ 已写入: {args.file}")

        if not args.no_verify:
            ok = run_godot_verify(args.project)
            if not ok:
                print("\n⚠️  文件已写入但验证失败，请检查上方错误信息")
                sys.exit(2)


if __name__ == "__main__":
    main()
