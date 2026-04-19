// Edge Softening Shader
// Softens sprite edges to reduce harsh vector feel
// Used on: Character sprites, foreground elements

shader_type canvas_item;

// Edge control parameters
uniform float edge_softness : hint_range(0.0, 0.1) = 0.02;
uniform float edge_threshold : hint_range(0.0, 1.0) = 0.5;

// Optional glow effect
uniform bool enable_glow = false;
uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 0.3);
uniform float glow_size : hint_range(0.0, 0.05) = 0.01;

void fragment() {
	// Sample base texture
	vec4 base_color = texture(TEXTURE, UV);
	float base_alpha = base_color.a;

	// Apply edge softening using smoothstep
	// This creates a gradual fade at the alpha boundary
	float softened_alpha = smoothstep(edge_threshold - edge_softness, edge_threshold + edge_softness, base_alpha);

	// Optional glow effect (samples neighboring pixels)
	vec3 final_color = base_color.rgb;
	float final_alpha = softened_alpha;

	if (enable_glow && base_alpha < 0.1) {
		// Sample surrounding pixels to detect edge proximity
		vec2 pixel_size = 1.0 / vec2(textureSize(TEXTURE, 0));
		float edge_detect = 0.0;

		// 8-direction sampling
		edge_detect += texture(TEXTURE, UV + vec2(-1.0, -1.0) * pixel_size * glow_size * 10.0).a;
		edge_detect += texture(TEXTURE, UV + vec2(0.0, -1.0) * pixel_size * glow_size * 10.0).a;
		edge_detect += texture(TEXTURE, UV + vec2(1.0, -1.0) * pixel_size * glow_size * 10.0).a;
		edge_detect += texture(TEXTURE, UV + vec2(-1.0, 0.0) * pixel_size * glow_size * 10.0).a;
		edge_detect += texture(TEXTURE, UV + vec2(1.0, 0.0) * pixel_size * glow_size * 10.0).a;
		edge_detect += texture(TEXTURE, UV + vec2(-1.0, 1.0) * pixel_size * glow_size * 10.0).a;
		edge_detect += texture(TEXTURE, UV + vec2(0.0, 1.0) * pixel_size * glow_size * 10.0).a;
		edge_detect += texture(TEXTURE, UV + vec2(1.0, 1.0) * pixel_size * glow_size * 10.0).a;

		edge_detect /= 8.0;

		// If we're near an edge, blend in glow color
		if (edge_detect > 0.1) {
			final_color = mix(final_color, glow_color.rgb, glow_color.a * edge_detect);
			final_alpha = max(final_alpha, glow_color.a * edge_detect);
		}
	}

	// Output final color with softened alpha
	COLOR = vec4(final_color, final_alpha * base_color.a);
}
