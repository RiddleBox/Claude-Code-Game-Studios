# app/dependency_graph.gd
# 依赖关系图管理
# 负责模块依赖解析、循环依赖检测和拓扑排序

class_name DependencyGraph
extends RefCounted

## 模块依赖表 {module_id: [dependency_ids]}
var _dependencies: Dictionary = {}

## 反向依赖表 {module_id: [dependent_ids]}
var _reverse_dependencies: Dictionary = {}

## 模块信息表 {module_id: module_info}
var _module_info: Dictionary = {}

## 添加模块到依赖图
## @param module_id: 模块ID
## @param dependencies: 依赖模块ID列表
## @param optional_dependencies: 可选依赖模块ID列表
## @param module_info: 模块额外信息
func add_module(module_id: String, dependencies: Array[String] = [],
                optional_dependencies: Array[String] = [], module_info: Dictionary = {}) -> void:

	# 存储依赖关系
	_dependencies[module_id] = dependencies.duplicate()
	_module_info[module_id] = module_info.duplicate()
	_module_info[module_id]["optional_dependencies"] = optional_dependencies.duplicate()

	# 更新反向依赖表
	for dep_id in dependencies:
		if not dep_id in _reverse_dependencies:
			_reverse_dependencies[dep_id] = []
		if not module_id in _reverse_dependencies[dep_id]:
			_reverse_dependencies[dep_id].append(module_id)

	# 可选依赖不加入反向依赖表（模块可降级运行）

## 移除模块从依赖图
## @param module_id: 模块ID
func remove_module(module_id: String) -> void:
	# 从依赖表中移除
	_dependencies.erase(module_id)
	_module_info.erase(module_id)

	# 从所有反向依赖中移除
	for dep_id in _reverse_dependencies.keys():
		if module_id in _reverse_dependencies[dep_id]:
			_reverse_dependencies[dep_id].erase(module_id)

	# 移除该模块的反向依赖条目
	_reverse_dependencies.erase(module_id)

## 获取模块的依赖列表
## @param module_id: 模块ID
## @return: 依赖模块ID列表
func get_dependencies(module_id: String) -> Array[String]:
	return _dependencies.get(module_id, []).duplicate()

## 获取模块的可选依赖列表
## @param module_id: 模块ID
## @return: 可选依赖模块ID列表
func get_optional_dependencies(module_id: String) -> Array[String]:
	var info = _module_info.get(module_id, {})
	return info.get("optional_dependencies", []).duplicate()

## 获取依赖该模块的模块列表
## @param module_id: 模块ID
## @return: 依赖此模块的模块ID列表
func get_dependents(module_id: String) -> Array[String]:
	return _reverse_dependencies.get(module_id, []).duplicate()

## 获取模块的完整依赖链（递归）
## @param module_id: 模块ID
## @param visited: 已访问模块集合（内部使用）
## @return: 所有依赖模块ID列表（包括间接依赖）
func get_dependency_chain(module_id: String, visited: Array[String] = []) -> Array[String]:
	if module_id in visited:
		return []  # 避免无限递归

	visited.append(module_id)
	var chain: Array[String] = []

	# 获取直接依赖
	var deps = get_dependencies(module_id)
	for dep_id in deps:
		# 递归获取依赖的依赖
		var sub_chain = get_dependency_chain(dep_id, visited)
		for sub_dep in sub_chain:
			if not sub_dep in chain:
				chain.append(sub_dep)

		# 添加直接依赖
		if not dep_id in chain:
			chain.append(dep_id)

	return chain

## 拓扑排序（Kahn算法）
## @return: 按依赖顺序排序的模块ID列表，空数组表示有循环依赖
func topological_sort() -> Array[String]:
	# 复制依赖表
	var deps_copy: Dictionary = {}
	for module_id in _dependencies.keys():
		deps_copy[module_id] = _dependencies[module_id].duplicate()

	# 计算入度
	var in_degree: Dictionary = {}
	for module_id in deps_copy.keys():
		in_degree[module_id] = 0

	for module_id in deps_copy.keys():
		for dep_id in deps_copy[module_id]:
			if dep_id in in_degree:
				in_degree[dep_id] += 1
			else:
				in_degree[dep_id] = 1

	# 初始化队列（入度为0的节点）
	var queue: Array[String] = []
	for module_id in in_degree.keys():
		if in_degree[module_id] == 0:
			queue.append(module_id)

	# 拓扑排序
	var sorted_list: Array[String] = []
	var visited_count = 0

	while not queue.is_empty():
		var module_id = queue.pop_front()
		sorted_list.append(module_id)
		visited_count += 1

		# 减少依赖节点的入度
		for dep_id in deps_copy.get(module_id, []):
			if dep_id in in_degree:
				in_degree[dep_id] -= 1
				if in_degree[dep_id] == 0:
					queue.append(dep_id)

	# 检查是否有循环依赖
	if visited_count != _dependencies.size():
		push_error("DependencyGraph: Circular dependency detected!")
		return []

	return sorted_list

## 检测循环依赖（DFS算法）
## @return: 循环依赖链列表，空数组表示无循环依赖
func detect_cycles() -> Array[Array]:
	var visited: Dictionary = {}
	var recursion_stack: Dictionary = {}
	var cycles: Array[Array] = []
	var current_path: Array[String] = []

	for module_id in _dependencies.keys():
		if not visited.get(module_id, false):
			_dfs_detect_cycles(module_id, visited, recursion_stack, current_path, cycles)

	return cycles

## 深度优先搜索检测循环依赖（内部方法）
func _dfs_detect_cycles(module_id: String, visited: Dictionary, recursion_stack: Dictionary,
                       current_path: Array[String], cycles: Array[Array]) -> void:

	visited[module_id] = true
	recursion_stack[module_id] = true
	current_path.append(module_id)

	for dep_id in _dependencies.get(module_id, []):
		if not visited.get(dep_id, false):
			_dfs_detect_cycles(dep_id, visited, recursion_stack, current_path, cycles)
		elif recursion_stack.get(dep_id, false):
			# 找到循环依赖
			var cycle_start = current_path.find(dep_id)
			if cycle_start != -1:
				var cycle = current_path.slice(cycle_start, current_path.size())
				cycles.append(cycle.duplicate())

	current_path.pop_back()
	recursion_stack[module_id] = false

## 验证依赖关系
## @param available_modules: 可用模块ID列表
## @return: 验证结果字典 {valid: bool, missing_deps: Dictionary, cycles: Array[Array]}
func validate_dependencies(available_modules: Array) -> Dictionary:
	var result = {
		"valid": true,
		"missing_deps": {},  # {module_id: [missing_dep_ids]}
		"cycles": []
	}

	# 检查缺失依赖
	for module_id in _dependencies.keys():
		var missing = []
		for dep_id in _dependencies[module_id]:
			if not dep_id in available_modules:
				missing.append(dep_id)

		if not missing.is_empty():
			result["missing_deps"][module_id] = missing
			result["valid"] = false

	# 检查循环依赖
	var cycles = detect_cycles()
	if not cycles.is_empty():
		result["cycles"] = cycles
		result["valid"] = false

	return result

## 获取模块启动顺序（考虑优先级）
## @param module_priorities: 模块优先级字典 {module_id: priority_value}
## @return: 启动顺序列表
func get_startup_order(module_priorities: Dictionary = {}) -> Array[String]:
	# 先进行拓扑排序
	var topological_order = topological_sort()
	if topological_order.is_empty():
		return []

	# 如果有优先级信息，在依赖顺序基础上按优先级分组
	if not module_priorities.is_empty():
		var priority_groups: Dictionary = {}

		# 按优先级分组
		for module_id in topological_order:
			var priority = module_priorities.get(module_id, 0)
			if not priority in priority_groups:
				priority_groups[priority] = []
			priority_groups[priority].append(module_id)

		# 按优先级排序（高优先级先启动）
		var sorted_priorities = priority_groups.keys()
		sorted_priorities.sort()
		sorted_priorities.reverse()  # 高优先级在前

		var result: Array[String] = []
		for priority in sorted_priorities:
			result.append_array(priority_groups[priority])

		return result

	return topological_order

## 获取依赖图的可视化表示（用于调试）
## @return: Graphviz DOT格式字符串
func to_dot_format() -> String:
	var dot_lines: PackedStringArray = []
	dot_lines.append("digraph DependencyGraph {")
	dot_lines.append("  rankdir=LR;")
	dot_lines.append("  node [shape=box, style=filled, fillcolor=lightblue];")

	# 添加节点
	for module_id in _dependencies.keys():
		var info = _module_info.get(module_id, {})
		var label = "%s\\n%s" % [module_id, info.get("category", "unknown")]
		dot_lines.append('  "%s" [label="%s"];' % [module_id, label])

	# 添加边
	for module_id in _dependencies.keys():
		for dep_id in _dependencies[module_id]:
			dot_lines.append('  "%s" -> "%s";' % [module_id, dep_id])

	dot_lines.append("}")
	return "\n".join(dot_lines)