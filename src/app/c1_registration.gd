# app/c1_registration.gd
# C1角色动画系统注册函数模板
# 需要在app.gd中集成

## 注册C1角色动画系统
func _register_c1_animation_system() -> void:
	var module_class = load("res://src/gameplay/c1_character_animation_system/c1_character_animation_system.gd")
	if not module_class:
		push_error("[App] 无法加载C1角色动画系统模块类")
		return

	var config = _config.get("c1_character_animation_system", {})
	var success = _module_loader.register_module(
		"c1_character_animation_system",
		module_class,
		config,
		["f2_state_machine"],  # 依赖F2状态机
		[],  # 无可选依赖
		60   # 中等优先级
	)

	if success:
		print("[App] C1角色动画系统已注册")
	else:
		push_error("[App] C1角色动画系统注册失败")