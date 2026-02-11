shader_type canvas_item;

uniform sampler2D backbuffer : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec3 tint : source_color = vec3(0.49, 0.773, 0.769);
uniform float contrast : hint_range(0.0, 1.0) = 0.4;

float random(in vec3 pos) {
  return fract(sin(dot(pos.xyz, vec3(70.9898, 78.233, 32.4355))) * 43758.5453123);
}

void fragment() {
	vec3 color = textureLod(backbuffer, SCREEN_UV, 0).rgb;
	
	if (color.g < 0.90 || color.b < 0.80) {
		discard;
	}
	
	COLOR.rgb *= tint + vec3(contrast) * random(vec3(UV, TIME));
	
}
