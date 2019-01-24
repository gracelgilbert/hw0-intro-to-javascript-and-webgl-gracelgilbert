#version 300 es

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.
// uniform mat4 u_ViewProj;
uniform highp int u_Time;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.
float offsetFunction(vec4 pos) {
    return 0.05 * sin(pos.x * pos.y * pos.z * float(u_Time) / 5.0) -
           0.01 * cos((pos.x + 20.0) * (pos.y - 5.0) * (pos.z + 15.0) * 50.0);
}

vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d, vec4 pos )
{
    return a + b*cos( 6.28318*(c*t+d) ) * sin(float(u_Time) / 300.0);
}
void main()
{
    // Material base color (before shading)
        vec4 diffuseColor = u_Color;

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        // diffuseTerm = clamp(diffuseTerm, 0, 1);
    vec3 colorVec = palette(diffuseTerm, vec3(0.8, 0.6, 0.5), vec3(0.2, 0.4, 0.3), vec3(1.8, 1.0, 1.0), vec3(0.0, 0.35, 0.2), fs_Pos);

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        // Compute final shaded color
                out_Col = 0.4 * vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a) + 0.6 * vec4(colorVec.rgb, 1.0);

    // out_Col = vec4(colorVec.rgb, 1.0) ;
}
