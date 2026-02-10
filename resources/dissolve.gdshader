shader_type canvas_item;

instance uniform float dissolve : hint_range(0.0, 1.0) = 0.0;
uniform bool flickering_dissolve = true;

/*
float srandom(in vec2 st) {
  return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453);
}
*/

float srandom(in vec3 pos) {
  return -1. + 2. * fract(sin(dot(pos.xyz, vec3(70.9898, 78.233, 32.4355))) * 43758.5453123);
}

void fragment() {
	COLOR.a *= step(srandom(vec3(UV, float(flickering_dissolve) * dissolve)), 1. - dissolve);
}

