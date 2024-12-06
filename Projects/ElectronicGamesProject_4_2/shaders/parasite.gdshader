shader_type canvas_item;

uniform float bright_amount;
uniform float alpha_amount;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 c = texture(TEXTURE, UV);
    c.rgb += vec3(bright_amount);
	//c.a = alpha_amount;
    COLOR = c;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
