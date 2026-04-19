// Paper Overlay Shader
// Applies paper grain texture to sprites for unified material feel
// Used on: Character sprites, UI elements, background layers

shader_type canvas_item;

// Texture inputs
uniform sampler2D paper_texture : hint_default_white, filter_linear_mipmap, repeat_enable;

// Control parameters
uniform float paper_strength : hint_range(0.0, 1.0) = 0.3;
uniform vec2 paper_scale = vec2(2.0, 2.0);
uniform vec2 paper_offset = vec2(0.0, 0.0);

// Color adjustment
uniform float brightness_adjust : hint_range(-0.2, 0.2) = 0.0;
uniform float contrast_adjust : hint_range(0.8, 1.2) = 1.0;

void fragment() {
	// Sample base sprite color
	vec4 base_color = texture(TEXTURE, UV);

	// Sample paper texture with scaling and offset
	vec2 paper_uv = UV * paper_scale + paper_offset;
	vec4 paper = texture(paper_texture, paper_uv);

	// Convert paper to grayscale if it's RGB (use luminance formula)
	float paper_value = dot(paper.rgb, vec3(0.299, 0.587, 0.114));

	// Apply paper texture as multiply blend
	// paper_value ranges from 0-1, we want it centered around 1.0 for neutral
	// Remap from [0,1] to [1-strength, 1+strength] for subtle effect
	float paper_multiplier = mix(1.0, paper_value, paper_strength);
	vec3 textured_color = base_color.rgb * paper_multiplier;

	// Apply brightness and contrast adjustments
	textured_color = (textured_color - 0.5) * contrast_adjust + 0.5 + brightness_adjust;

	// Clamp to valid range
	textured_color = clamp(textured_color, 0.0, 1.0);

	// Output with original alpha
	COLOR = vec4(textured_color, base_color.a);
}
