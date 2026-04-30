# ui/p2_fragment_log_ui/p2_fragment_log_ui.gd
# P2 — 碎片日志 UI（Fragment Log UI）
# 玩家回顾碎片的界面
# 实现 IModule 接口，支持模块化架构

class_name P2FragmentLogUI
extends Node

## IModule 接口实现
var module_id: String = "p2_fragment_log_ui"
var module_name: String = "碎片日志UI"
var module_version: String = "1.0.0"
var dependencies: Array[String] = ["ui_framework"]
var optional_dependencies: Array[String] = ["c3_fragment_system", "fe3_affinity_system"]
var config_path: String = "res://data/config/p2_fragment_log_ui.json"
var category: String = "ui"
var priority: String = "medium"
var status: IModule.ModuleStatus = IModule.ModuleStatus.UNINITIALIZED
var last_error: Dictionary = {}

## ==================== 信号 ====================

## 碎片被选中时触发
signal fragment_selected(fragment_id: String)

## ==================== 私有变量 ====================

## UI框架引用
var _ui_framework: Node = null

## C3碎片系统引用（可选）
var _c3_fragments: Node = null

## Fe3好感度系统引用（可选）
var _fe3_affinity: Node = null

## 当前筛选类型
var _current_filter: String = "all"

## 当前排序方式
var _current_sort: String = "newest"

## UI是否可见
var _is_visible: bool = false

## UI 节点
var _panel: Control = null
var _title_label: Label = null
var _fragment_list: VBoxContainer = null
var _scroll_container: ScrollContainer = null
var _detail_panel: Control = null
var _detail_title: Label = null
var _detail_text: RichTextLabel = null
var _close_button: Button = null

## 当前选中的碎片
var _selected_fragment_id: String = ""

## ==================== IModule 接口方法 ====================

## IModule.initialize() 实现
func initialize(_config: Dictionary = {}) -> bool:
	print("[P2] 初始化碎片日志UI...")
	status = IModule.ModuleStatus.INITIALIZING

	# 获取依赖模块
	var app = get_parent()
	if not app or not app.has_method("get_module"):
		push_error("[P2] 无法获取 App 节点")
		return false

	_ui_framework = app.get_module("ui_framework")
	if not _ui_framework:
		push_error("[P2] 无法获取 UI框架模块")
		return false

	# 获取可选依赖
	_c3_fragments = app.get_module("c3_fragment_system")
	_fe3_affinity = app.get_module("fe3_affinity_system")

	# 创建 UI
	_create_ui()

	status = IModule.ModuleStatus.INITIALIZED
	print("[P2] 碎片日志UI初始化完成")
	return true

## IModule.start() 实现
func start() -> bool:
	print("[P2] 启动碎片日志UI...")
	status = IModule.ModuleStatus.STARTING

	status = IModule.ModuleStatus.RUNNING
	print("[P2] 碎片日志UI启动完成")
	return true

## IModule.stop() 实现
func stop() -> void:
	print("[P2] 停止碎片日志UI...")
	status = IModule.ModuleStatus.STOPPING

	status = IModule.ModuleStatus.STOPPED
	print("[P2] 碎片日志UI已停止")

## IModule.get_module_info() 实现
func get_module_info() -> Dictionary:
	return {
		"id": module_id,
		"name": module_name,
		"version": module_version,
		"category": category,
		"priority": priority,
		"status": status,
		"dependencies": dependencies,
		"optional_dependencies": optional_dependencies,
		"is_visible": _is_visible,
		"current_filter": _current_filter,
		"current_sort": _current_sort
	}

## IModule.is_healthy() 实现
func is_healthy() -> bool:
	return status == IModule.ModuleStatus.RUNNING

## IModule.get_last_error() 实现
func get_last_error() -> Dictionary:
	return last_error

## ==================== 公共 API ====================

## 显示碎片日志
func show() -> void:
	_is_visible = true
	if _panel:
		_panel.visible = true
	print("[P2] 显示碎片日志")
	_refresh_fragment_list()

## 隐藏碎片日志
func hide() -> void:
	_is_visible = false
	if _panel:
		_panel.visible = false
	print("[P2] 隐藏碎片日志")

## 切换显示状态
func toggle() -> void:
	if _is_visible:
		hide()
	else:
		show()

## 设置筛选类型
func set_filter(filter_type: String) -> void:
	_current_filter = filter_type
	print("[P2] 设置筛选: %s" % filter_type)
	if _is_visible:
		_refresh_fragment_list()

## 设置排序方式
func set_sort(sort_type: String) -> void:
	_current_sort = sort_type
	print("[P2] 设置排序: %s" % sort_type)
	if _is_visible:
		_refresh_fragment_list()

## 标记碎片为已读
func mark_fragment_read(fragment_id: String) -> void:
	if _c3_fragments and _c3_fragments.has_method("mark_read"):
		_c3_fragments.mark_read(fragment_id)
		if _is_visible:
			_refresh_fragment_list()

## 获取当前显示的碎片列表
func get_current_fragments() -> Array:
	if not _c3_fragments or not _c3_fragments.has_method("get_all"):
		return []

	var fragments: Array
	match _current_filter:
		"all":
			fragments = _c3_fragments.get_all()
		"unread":
			fragments = _c3_fragments.get_unread()
		"dialogue":
			fragments = _c3_fragments.get_by_type("dialogue")
		"scene":
			fragments = _c3_fragments.get_by_type("scene")
		"object":
			fragments = _c3_fragments.get_by_type("object")
		"emotion":
			fragments = _c3_fragments.get_by_type("emotion")
		_:
			fragments = _c3_fragments.get_all()

	# 排序已在get_*方法中处理
	return fragments

## ==================== 私有方法 ====================

## 创建UI界面
func _create_ui() -> void:
	if not _ui_framework:
		push_error("[P2] UI框架未初始化")
		return

	# 创建主面板
	_panel = _ui_framework.create_panel()

	if not _panel:
		push_error("[P2] 创建主面板失败")
		return

	# 配置面板属性
	_panel.custom_minimum_size = Vector2(400, 600)
	_panel.position = Vector2(100, 100)
	_panel.visible = false

	# 添加到F1窗口系统
	var app = get_parent()
	if app:
		var f1 = app.get_module("f1_window_system")
		if f1 and f1.has_method("add_ui_element"):
			f1.add_ui_element(_panel)

	# 创建内容容器
	var content = VBoxContainer.new()
	content.name = "Content"
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.add_theme_constant_override("separation", 8)
	_panel.add_child(content)

	# 顶部工具栏
	var toolbar = HBoxContainer.new()
	toolbar.name = "Toolbar"
	content.add_child(toolbar)

	# 筛选按钮
	var filter_label = Label.new()
	filter_label.text = "筛选:"
	toolbar.add_child(filter_label)

	var filter_options = ["全部", "未读", "对话", "场景", "物品", "情绪"]
	var filter_keys = ["all", "unread", "dialogue", "scene", "object", "emotion"]
	for i in filter_options.size():
		var btn = Button.new()
		btn.text = filter_options[i]
		btn.custom_minimum_size = Vector2(60, 30)
		btn.pressed.connect(_on_filter_pressed.bind(filter_keys[i]))
		toolbar.add_child(btn)

	# 排序按钮
	toolbar.add_child(VSeparator.new())
	var sort_label = Label.new()
	sort_label.text = "排序:"
	toolbar.add_child(sort_label)

	var sort_btn = Button.new()
	sort_btn.text = "时间"
	sort_btn.custom_minimum_size = Vector2(60, 30)
	sort_btn.pressed.connect(_on_sort_pressed.bind("time"))
	toolbar.add_child(sort_btn)

	# 碎片列表容器
	var scroll = ScrollContainer.new()
	scroll.name = "ScrollContainer"
	scroll.custom_minimum_size = Vector2(0, 400)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)

	_fragment_list = VBoxContainer.new()
	_fragment_list.name = "FragmentList"
	_fragment_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_fragment_list)

	# 详情面板
	_detail_panel = PanelContainer.new()
	_detail_panel.name = "DetailPanel"
	_detail_panel.custom_minimum_size = Vector2(0, 150)
	_detail_panel.visible = false
	content.add_child(_detail_panel)

	var detail_content = VBoxContainer.new()
	detail_content.name = "DetailContent"
	_detail_panel.add_child(detail_content)

	_detail_title = Label.new()
	_detail_title.name = "DetailTitle"
	_detail_title.add_theme_font_size_override("font_size", 16)
	detail_content.add_child(_detail_title)

	_detail_text = RichTextLabel.new()
	_detail_text.name = "DetailText"
	_detail_text.custom_minimum_size = Vector2(0, 100)
	_detail_text.bbcode_enabled = true
	_detail_text.fit_content = true
	detail_content.add_child(_detail_text)

	print("[P2] UI界面创建完成")

## 刷新碎片列表
func _refresh_fragment_list() -> void:
	if not _fragment_list:
		return

	# 清空现有列表
	for child in _fragment_list.get_children():
		child.queue_free()

	var fragments = get_current_fragments()
	print("[P2] 刷新碎片列表，共 %d 条" % fragments.size())

	# 创建碎片项
	for fragment in fragments:
		var item = _create_fragment_item(fragment)
		_fragment_list.add_child(item)

## 创建碎片列表项
func _create_fragment_item(fragment: Dictionary) -> Control:
	var item = PanelContainer.new()
	item.custom_minimum_size = Vector2(0, 60)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	item.add_child(hbox)

	# 类型图标
	var type_label = Label.new()
	type_label.custom_minimum_size = Vector2(40, 0)
	type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	match fragment.get("type", "dialogue"):
		"dialogue": type_label.text = "💬"
		"scene": type_label.text = "🎬"
		"object": type_label.text = "📦"
		"emotion": type_label.text = "💭"
	hbox.add_child(type_label)

	# 内容预览
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)

	var title = Label.new()
	title.text = fragment.get("id", "未知碎片")
	title.add_theme_font_size_override("font_size", 14)
	vbox.add_child(title)

	var preview = Label.new()
	var content = fragment.get("content", "")
	preview.text = content.substr(0, 40) + ("..." if content.length() > 40 else "")
	preview.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(preview)

	# 未读标记
	if not fragment.get("is_read", false):
		var unread = Label.new()
		unread.text = "●"
		unread.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		hbox.add_child(unread)

	# 点击事件
	var button = Button.new()
	button.flat = true
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.pressed.connect(_on_fragment_selected.bind(fragment))
	item.add_child(button)

	return item

## 筛选按钮回调
func _on_filter_pressed(filter_key: String) -> void:
	_current_filter = filter_key
	_refresh_fragment_list()
	print("[P2] 切换筛选: %s" % filter_key)

## 排序按钮回调
func _on_sort_pressed(sort_key: String) -> void:
	_current_sort = sort_key
	_refresh_fragment_list()
	print("[P2] 切换排序: %s" % sort_key)

## 碎片选中回调
func _on_fragment_selected(fragment: Dictionary) -> void:
	if not _detail_panel:
		return

	_detail_panel.visible = true
	_detail_title.text = fragment.get("id", "未知碎片")
	_detail_text.text = fragment.get("content", "")

	# 标记为已读
	if _c3_fragments and _c3_fragments.has_method("mark_as_read"):
		_c3_fragments.mark_as_read(fragment.get("id", ""))

	print("[P2] 选中碎片: %s" % fragment.get("id", ""))

## 获取性格展示标签
func _get_personality_display_label() -> String:
	var app = get_parent()
	if not app:
		return "平静"

	var c5_personality = app.get_module("c5_personality_variable_system")
	if c5_personality and c5_personality.has_method("get_display_label"):
		return c5_personality.get_display_label()

	return "平静"
