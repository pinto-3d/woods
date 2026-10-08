shader_type spatial;
render_mode unshaded;

uniform float pixel_size = 1.0;

uniform float seed = 1.0;

uniform float resolution = 8.0;
uniform vec3 tint;

uniform float min_brightness = 0.0;
uniform float max_brightness = 1.0;

varying vec3 world_pos;

float rand(vec2 co) {
	return fract(sin(dot(co + seed, vec2(12.9898, 78.233))) * 43758.5453);
}

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	// Called for every vertex the material is visible on.
}


void fragment() {
	// Called for every pixel the material is visible on.
	vec2 grid_pos = floor(world_pos.xy / pixel_size);
	uvec2 res = uvec2(UV * resolution);
	
	float brightness = rand(vec2(res));
	brightness *= max_brightness + min_brightness;
	
	ALBEDO = tint * vec3(brightness);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
