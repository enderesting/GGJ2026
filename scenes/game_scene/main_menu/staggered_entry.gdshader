shader_type canvas_item;

uniform float delay = 0.0;
uniform float offset = 100.0;
uniform float speed = 7.5;

void vertex() {
	VERTEX = VERTEX - vec2(offset * smoothstep(1, 0, speed*(TIME - delay)), 0);
}
