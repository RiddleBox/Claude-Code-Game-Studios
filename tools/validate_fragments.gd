extends SceneTree
## Fragment JSON Validator
## 验证碎片JSON文件格式是否符合规范

const VALID_TYPES := ["scene", "dialogue", "object", "emotion"]
const REQUIRED_METADATA_KEYS := ["file_name", "description", "total_fragments", "created_at"]
const REQUIRED_FRAGMENT_KEYS := ["id", "type", "content", "tags", "emotional_weight", "unlock_conditions", "metadata"]
const REQUIRED_UNLOCK_KEYS := ["min_affinity", "required_fragments", "time_range"]
const REQUIRED_FRAGMENT_META_KEYS := ["author", "created_at", "notes"]

var errors: Array[String] = []
var warnings: Array[String] = []

func _init() -> void:
	var args := OS.get_cmdline_args()
	var file_path := ""

	# 解析命令行参数
	for i in range(args.size()):
		if args[i] == "--path" and i + 1 < args.size():
			file_path = args[i + 1]
			break

	if file_path.is_empty():
		print("Usage: godot --headless --script tools/validate_fragments.gd -- --path <json_file_path>")
		quit(1)
		return

	validate_file(file_path)

	# 输出结果
	if errors.is_empty() and warnings.is_empty():
		print("✓ Validation passed: %s" % file_path)
		quit(0)
	else:
		if not errors.is_empty():
			print("\n❌ ERRORS:")
			for error in errors:
				print("  - %s" % error)

		if not warnings.is_empty():
			print("\n⚠ WARNINGS:")
			for warning in warnings:
				print("  - %s" % warning)

		quit(1 if not errors.is_empty() else 0)

func validate_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		errors.append("File not found: %s" % path)
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("Failed to open file: %s" % path)
		return

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_text)

	if parse_result != OK:
		errors.append("JSON parse error at line %d: %s" % [json.get_error_line(), json.get_error_message()])
		return

	var data: Dictionary = json.data
	validate_structure(data, path)

func validate_structure(data: Dictionary, file_path: String) -> void:
	# 验证顶层结构
	if not data.has("metadata"):
		errors.append("Missing 'metadata' field")
		return

	if not data.has("fragments"):
		errors.append("Missing 'fragments' field")
		return

	validate_metadata(data.metadata)
	validate_fragments(data.fragments, data.metadata.get("total_fragments", 0))

func validate_metadata(metadata: Dictionary) -> void:
	for key in REQUIRED_METADATA_KEYS:
		if not metadata.has(key):
			errors.append("metadata: Missing required key '%s'" % key)

	if metadata.has("total_fragments"):
		if not metadata.total_fragments is int or metadata.total_fragments <= 0:
			errors.append("metadata.total_fragments: Must be a positive integer")

func validate_fragments(fragments: Array, expected_count: int) -> void:
	if fragments.size() != expected_count:
		warnings.append("Fragment count mismatch: expected %d, got %d" % [expected_count, fragments.size()])

	var fragment_ids := {}

	for i in range(fragments.size()):
		var frag: Dictionary = fragments[i]
		validate_fragment(frag, i, fragment_ids)

func validate_fragment(frag: Dictionary, index: int, id_registry: Dictionary) -> void:
	var prefix := "fragments[%d]" % index

	# 验证必需字段
	for key in REQUIRED_FRAGMENT_KEYS:
		if not frag.has(key):
			errors.append("%s: Missing required key '%s'" % [prefix, key])

	# 验证id唯一性
	if frag.has("id"):
		var frag_id: String = frag.id
		if frag_id in id_registry:
			errors.append("%s.id: Duplicate fragment ID '%s' (first seen at index %d)" % [prefix, frag_id, id_registry[frag_id]])
		else:
			id_registry[frag_id] = index

	# 验证type
	if frag.has("type"):
		if not frag.type in VALID_TYPES:
			errors.append("%s.type: Invalid type '%s' (must be one of: %s)" % [prefix, frag.type, ", ".join(VALID_TYPES)])

	# 验证content
	if frag.has("content"):
		if not frag.content is String or frag.content.is_empty():
			errors.append("%s.content: Must be a non-empty string" % prefix)

	# 验证tags
	if frag.has("tags"):
		if not frag.tags is Array:
			errors.append("%s.tags: Must be an array" % prefix)
		elif frag.tags.is_empty():
			warnings.append("%s.tags: Empty tags array" % prefix)

	# 验证emotional_weight
	if frag.has("emotional_weight"):
		var weight: float = frag.emotional_weight
		if weight < 0.0 or weight > 1.0:
			errors.append("%s.emotional_weight: Must be between 0.0 and 1.0 (got %.2f)" % [prefix, weight])

	# 验证unlock_conditions
	if frag.has("unlock_conditions"):
		validate_unlock_conditions(frag.unlock_conditions, prefix)

	# 验证metadata
	if frag.has("metadata"):
		validate_fragment_metadata(frag.metadata, prefix)

func validate_unlock_conditions(conditions: Dictionary, prefix: String) -> void:
	var cond_prefix := "%s.unlock_conditions" % prefix

	for key in REQUIRED_UNLOCK_KEYS:
		if not conditions.has(key):
			errors.append("%s: Missing required key '%s'" % [cond_prefix, key])

	# 验证min_affinity
	if conditions.has("min_affinity"):
		if not conditions.min_affinity is int or conditions.min_affinity < 0:
			errors.append("%s.min_affinity: Must be a non-negative integer" % cond_prefix)

	# 验证required_fragments
	if conditions.has("required_fragments"):
		if not conditions.required_fragments is Array:
			errors.append("%s.required_fragments: Must be an array" % cond_prefix)

	# 验证time_range
	if conditions.has("time_range"):
		if conditions.time_range != null:
			if not conditions.time_range is Dictionary:
				errors.append("%s.time_range: Must be a dictionary or null" % cond_prefix)
			else:
				var time_range: Dictionary = conditions.time_range
				if not time_range.has("start_hour") or not time_range.has("end_hour"):
					errors.append("%s.time_range: Must have 'start_hour' and 'end_hour'" % cond_prefix)
				else:
					var start: int = time_range.start_hour
					var end: int = time_range.end_hour
					if start < 0 or start > 23 or end < 0 or end > 23:
						errors.append("%s.time_range: Hours must be between 0 and 23" % cond_prefix)

func validate_fragment_metadata(metadata: Dictionary, prefix: String) -> void:
	var meta_prefix := "%s.metadata" % prefix

	for key in REQUIRED_FRAGMENT_META_KEYS:
		if not metadata.has(key):
			warnings.append("%s: Missing recommended key '%s'" % [meta_prefix, key])
