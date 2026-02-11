shader_type canvas_item;

const float ASPECT_RATIO = 320.0 / 180.0;

uniform sampler2D mask : repeat_disable, filter_nearest;
uniform vec3 color_to_erase : source_color = vec3(0.4f, 0.89f, 0.89f);
uniform float rotation_speed = 4.0;
uniform float scaling_speed = 3.0;

uniform bool entry = true;
uniform float progress : hint_range(0.0, 1.0) = 0.0;

void vertex() {
	// Unstretch the sprite, assuming it's perfectly square
	VERTEX *= vec2(1.0 / ASPECT_RATIO, 1.0);
	
	// Let's rotate!
	float t = 0.25 * radians(progress * rotation_speed * 360.0);
	float scale = progress * scaling_speed;
	mat2 rotation_matrix = mat2(vec2(-sin(t), cos(t)), vec2(cos(t), sin(t)));
	VERTEX -= vec2(90.0); // pivoted to the center of the cog
	VERTEX *= rotation_matrix * scale;
	VERTEX += vec2(160.0, 90.0); // re-center
	// TODO: These transforms could be shmushed into a single 3x3 matrix
	
	// TODO replace this conditional with more appropriate arithmetic for GPU
	if (entry) {
		VERTEX -= vec2(160.0, 90.0);
		VERTEX *= 3.0;
		VERTEX += vec2(160.0, 90.0);
		UV -= vec2(0.5);
		UV *= 3.0;
		UV += vec2(0.5);
	}
	// TODO: Again, these transforms could be shmushed into a single 3x3 matrix
}

void fragment() {
	// Sample the sprite given through the uniform
	vec4 texel = texture(mask, UV);
	
	                        // Erase the white-ish outline pixels
	COLOR.a = texel.a * 1.0 - step(distance(texel.rgb, color_to_erase), 0.04)
	                        // Fill the interior hole of the cog sprite
	                        * step(0.2, distance(UV, vec2(0.5)));
	
	// TODO replace this conditional with more appropriate arithmetic for GPU
	if (entry) {
		COLOR.a = 1.0 - COLOR.a + step(0.5, distance(UV, vec2(0.5)));
	}
}

