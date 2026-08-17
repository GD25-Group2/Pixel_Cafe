uniform Image originalPalette; // 1px wide strip of original sprite colors (1 x H)
uniform Image targetPalette;   // 1px wide strip of replacement colors (1 x H)
uniform float paletteHeight;   // Total number of color entries (height in pixels)

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 spriteColor = Texel(texture, texture_coords);
    
    // Pass through fully transparent pixels
    if (spriteColor.a < 0.01) {
        return vec4(0.0);
    }

    // Default to unchanged color if no match is found
    vec4 finalColor = spriteColor;
    float minDistance = 100.0; // Color difference threshold

    // Loop through each row in the 1px-wide palette strip
    for (float i = 0.0; i < paletteHeight; i += 1.0) {
        // Calculate the center UV coordinate for row i (X = 0.5, Y = step)
        float v = (i + 0.5) / paletteHeight;
        vec2 paletteUV = vec2(0.5, v);

        vec4 origColor = Texel(originalPalette, paletteUV);

        // Calculate RGB distance between sprite pixel and original palette color
        float dist = distance(spriteColor.rgb, origColor.rgb);

        // If it's a match (within tolerance)
        if (dist < 0.05 && dist < minDistance) {
            minDistance = dist;
            // Get replacement color from the EXACT same position in target palette
            finalColor = Texel(targetPalette, paletteUV);
            finalColor.a *= spriteColor.a; // Maintain original opacity
        }
    }

    return finalColor * color;
}