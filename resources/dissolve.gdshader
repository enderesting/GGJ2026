shader_type canvas_item;

instance uniform float dissolve : hint_range(0.0, 1.0) = 0.0;

float srandom(in vec2 st) {
  return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	COLOR.a *= step(srandom(UV), 1. - dissolve);
}

