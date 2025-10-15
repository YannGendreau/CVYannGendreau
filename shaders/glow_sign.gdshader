shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.9, 0.4, 1.0); // couleur d’émission
uniform float glow_intensity : hint_range(0.0, 10.0) = 3.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // couleur de base (le sprite)
    COLOR = tex_color;
    
    // émission qui alimente le glow
    COLOR.rgb += glow_color.rgb * tex_color.a * glow_intensity;
}
