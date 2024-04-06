shader_type canvas_item;

uniform bool enabled = false;

void fragment() {
	if (enabled == true) {
	    COLOR = texture(TEXTURE, UV);
	    float avg = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
	    COLOR.rgb = vec3(avg);
	} else {
		COLOR = texture(TEXTURE, UV);
	}
}
