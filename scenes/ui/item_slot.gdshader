shader_type canvas_item;

uniform vec4 frame_color: source_color = vec4(1.0);
uniform float side = 1.65;
uniform float radius =  0.075;
uniform float thickness =  0.1;

void fragment() {
	vec2 center = vec2(0.5, 0.5);
	vec2 size = vec2(side, side) * 0.25;
	float d = length(max(abs(UV - center), size) - size) - radius;
	float frame = smoothstep(0.55, 0.45, abs(d / thickness) * 5.0);

	COLOR = vec4(frame_color.rgb, frame);
}
