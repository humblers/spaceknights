shader_type canvas_item;
render_mode blend_mix;

uniform float light_position_x : hint_range(-1, 1);
uniform float light_position_y : hint_range(-1, 1);
uniform float light_height : hint_range(0, 10);
uniform float light_energy : hint_range(0, 5);

varying vec4 local_rot;

void vertex() {
	local_rot.xy = normalize(WORLD_MATRIX * (EXTRA_MATRIX * vec4(1, 0, 0, 0))).xy;
	local_rot.zw = normalize(WORLD_MATRIX * (EXTRA_MATRIX * vec4(0, 1, 0, 0))).xy;
	local_rot.xy *= sign(SRC_RECT.z);
	local_rot.zw *= sign(SRC_RECT.w);
}

void fragment(){
	NORMAL.xy = mat2(local_rot.xy, local_rot.zw) * NORMAL.xy;
	vec4 color = texture(TEXTURE, UV);
	vec2 light_position = vec2(light_position_x, light_position_y);
	vec2 screen_uv = SCREEN_UV;
	screen_uv.y = 1.0 - screen_uv.y;
	vec2 dir = vec2(light_position - screen_uv);
	dir.x *= SCREEN_PIXEL_SIZE.y/SCREEN_PIXEL_SIZE.x;
	vec3 light = normalize(vec3(dir, light_height));
	float L = dot(NORMAL.xyz, light) * light_energy;
	vec4 lit = vec4(L * color.xyz, color.w);
	COLOR = lit;
}