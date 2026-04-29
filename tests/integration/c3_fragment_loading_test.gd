extends Node

## C3碎片系统JSON加载集成测试
## 验证碎片库加载、解锁条件检查、随机选择功能

var _c3: Node = null
var _test_results: Array[String] = []

func _ready() -> void:
	print("\n========== C3 Fragment Loading Test ==========\n")

	# 获取C3模块
	_c3 = get_node("/root/App/C3FragmentSystem")
	if not _c3:
		push_error("[Test] 无法获取C3模块")
		return

	# 等待模块初始化
	await get_tree().create_timer(0.5).timeout

	# 运行测试
	_test_fragment_pool_loaded()
	_test_unlockable_fragments()
	_test_add_fragment()
	_test_unlock_chain()
	_test_time_range_filtering()

	# 输出结果
	print("\n========== Test Results ==========")
	for result in _test_results:
		print(result)
	print("==================================\n")

## 测试1：碎片池是否正确加载
func _test_fragment_pool_loaded() -> void:
	var info = _c3.get_module_info()
	var pool_size = _c3._fragment_pool.size()

	if pool_size == 15:
		_test_results.append("[PASS] 碎片池加载: 15条碎片")
	else:
		_test_results.append("[FAIL] 碎片池加载: 期望15条，实际%d条" % pool_size)

	# 检查特定碎片是否存在
	var expected_ids = ["frag_001", "frag_002", "frag_c01"]
	for frag_id in expected_ids:
		if _c3._fragment_pool.has(frag_id):
			_test_results.append("[PASS] 碎片存在: %s" % frag_id)
		else:
			_test_results.append("[FAIL] 碎片缺失: %s" % frag_id)

## 测试2：解锁条件检查
func _test_unlockable_fragments() -> void:
	# 亲密度0时，应该只能解锁frag_001和frag_c01-c05
	var unlockable = _c3.get_unlockable_fragments(0, -1)

	if "frag_001" in unlockable:
		_test_results.append("[PASS] frag_001可解锁（亲密度0）")
	else:
		_test_results.append("[FAIL] frag_001应该可解锁（亲密度0）")

	if "frag_002" not in unlockable:
		_test_results.append("[PASS] frag_002不可解锁（需要亲密度5）")
	else:
		_test_results.append("[FAIL] frag_002不应该可解锁（需要亲密度5）")

	# 亲密度10时，应该能解锁更多
	var unlockable_10 = _c3.get_unlockable_fragments(10, -1)
	if unlockable_10.size() > unlockable.size():
		_test_results.append("[PASS] 亲密度10时可解锁碎片增加")
	else:
		_test_results.append("[FAIL] 亲密度10时可解锁碎片未增加")

## 测试3：添加碎片
func _test_add_fragment() -> void:
	var success = _c3.add_fragment("frag_001")

	if success:
		_test_results.append("[PASS] 成功添加frag_001")
	else:
		_test_results.append("[FAIL] 添加frag_001失败")

	# 检查碎片是否在玩家库中
	if _c3._fragments.has("frag_001"):
		var frag = _c3._fragments["frag_001"]
		_test_results.append("[PASS] frag_001已存储，内容: %s" % frag.content.substr(0, 20))
	else:
		_test_results.append("[FAIL] frag_001未存储")

	# 尝试重复添加
	var duplicate = _c3.add_fragment("frag_001")
	if not duplicate:
		_test_results.append("[PASS] 重复添加被正确拒绝")
	else:
		_test_results.append("[FAIL] 重复添加未被拒绝")

## 测试4：解锁链
func _test_unlock_chain() -> void:
	# frag_003需要frag_001作为前置
	var unlockable_before = _c3.get_unlockable_fragments(10, -1)

	if "frag_003" in unlockable_before:
		_test_results.append("[PASS] frag_003可解锁（已有frag_001）")
	else:
		_test_results.append("[FAIL] frag_003应该可解锁（已有frag_001）")

	# frag_004需要frag_002和frag_003
	if "frag_004" not in unlockable_before:
		_test_results.append("[PASS] frag_004不可解锁（缺少frag_002）")
	else:
		_test_results.append("[FAIL] frag_004不应该可解锁（缺少frag_002）")

## 测试5：时间范围过滤
func _test_time_range_filtering() -> void:
	# frag_c01限制在6-18点（日间）
	var unlockable_day = _c3.get_unlockable_fragments(0, 12)
	var unlockable_night = _c3.get_unlockable_fragments(0, 22)

	if "frag_c01" in unlockable_day:
		_test_results.append("[PASS] frag_c01在日间可解锁")
	else:
		_test_results.append("[FAIL] frag_c01应该在日间可解锁")

	if "frag_c01" not in unlockable_night:
		_test_results.append("[PASS] frag_c01在夜间不可解锁")
	else:
		_test_results.append("[FAIL] frag_c01不应该在夜间可解锁")

	# frag_c05限制在18-6点（夜间）
	if "frag_c05" not in unlockable_day:
		_test_results.append("[PASS] frag_c05在日间不可解锁")
	else:
		_test_results.append("[FAIL] frag_c05不应该在日间可解锁")

	if "frag_c05" in unlockable_night:
		_test_results.append("[PASS] frag_c05在夜间可解锁")
	else:
		_test_results.append("[FAIL] frag_c05应该在夜间可解锁")
