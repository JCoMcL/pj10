shader_type canvas_item;
uniform vec3 light: source_color = vec3(1.0);
uniform vec3 midtone: source_color = vec3(.5);
uniform vec3 dark: source_color = vec3(.2);
uniform bool active = false;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (active && COLOR.a > 0.0) {
		if (COLOR.b > 0.7)
			COLOR.rgb=light;
		else if (COLOR.b > 0.5)
			COLOR.rgb=midtone;
		else if (COLOR.b > 0.3)
			COLOR.rgb=dark;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
