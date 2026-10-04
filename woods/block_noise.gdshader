shader_type spatial;
render_mode unshaded;

float rand(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void vertex() {
	// Called for every vertex the material is visible on.
}


void fragment() {
	// Called for every pixel the material is visible on.
	uvec2 res = uvec2(UV * 16.0);
	float brightness = rand(vec2(res));
	
	
	ALBEDO = vec3(0.8,0.3,0.4) * vec3(brightness);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
