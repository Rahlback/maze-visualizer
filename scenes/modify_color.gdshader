shader_type canvas_item;

uniform vec4 board_color : source_color;
instance uniform vec4 replace_color : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float dist = length(tex_color.rgb - board_color.rgb);
	if (dist < 0.1) {
		COLOR = replace_color;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
