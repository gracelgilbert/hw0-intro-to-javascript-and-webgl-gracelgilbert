#version 300 es

//This is a vertex shader. While it is called a "shader" due to outdated conventions, this file
//is used to apply matrix transformations to the arrays of vertex data passed to it.
//Since this code is run on your GPU, each vertex is transformed simultaneously.
//If it were run on your CPU, each vertex would have to be processed in a FOR loop, one at a time.
//This simultaneous transformation allows your program to run much faster, especially when rendering
//geometry with millions of vertices.

uniform mat4 u_Model;       // The matrix that defines the transformation of the
                            // object we're rendering. In this assignment,
                            // this will be the result of traversing your scene graph.

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.
                            // This allows us to transform the object's normals properly
                            // if the object has been non-uniformly scaled.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.
                            // We've written a static matrix for you to use for HW2,
                            // but in HW3 you'll have to generate one yourself
uniform int u_Time;

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.

void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.
    vec4 posdx1 = vs_Pos + vec4(0.0001, 0, 0, 0);
    vec4 posdx2 = vs_Pos + vec4(-0.0001, 0, 0, 0);

    vec4 posdy1 = vs_Pos + vec4(0, 0.0001, 0, 0);
    vec4 posdy2 = vs_Pos + vec4(0, -0.0001, 0, 0);
    
    // float timeFloat = float(u_Time);

    vec4 offsetdx1 = posdx1 + vs_Nor * 0.05 * sin(posdx1.x * posdx1.y * posdx1.z * 50.0) -
                           vs_Nor * 0.01 * cos((posdx1.x + 20.0) * (posdx1.y - 5.0) * (posdx1.z + 15.0) * 50.0);

    vec4 offsetdx2 = posdx2 + vs_Nor * 0.05 * sin(posdx2.x * posdx2.y * posdx2.z * 50.0) -
                           vs_Nor * 0.01 * cos((posdx2.x + 20.0) * (posdx2.y - 5.0) * (posdx2.z + 15.0) * 50.0);

    vec4 offsetdy1 = posdy1 + vs_Nor * 0.05 * sin(posdy1.x * posdy1.y * posdy1.z * 50.0) -
                           vs_Nor * 0.01 * cos((posdy1.x + 20.0) * (posdy1.y - 5.0) * (posdy1.z + 15.0) * 50.0);

    vec4 offsetdy2 = posdy2 + vs_Nor * 0.05 * sin(posdy2.x * posdy2.y * posdy2.z * 50.0) -
                           vs_Nor * 0.01 * cos((posdy2.x + 20.0) * (posdy2.y - 5.0) * (posdy2.z + 15.0) * 50.0);

    vec3 slopex = vec3(offsetdx1 - offsetdx2);
    vec3 slopey = vec3(offsetdy1 - offsetdy2);
    // int test = u_Time;



    vec4 offset = vs_Pos + fs_Nor * 0.05 * sin(vs_Pos.x * vs_Pos.y * vs_Pos.z * float(u_Time) / 5.0) -
                           fs_Nor * 0.01 * cos((vs_Pos.x + 20.0) * (vs_Pos.y - 5.0) * (vs_Pos.z + 15.0) * 50.0);

    // fs_Nor = fs_Nor * 1.0 / (sin(vs_Pos.x * vs_Pos.y * vs_Pos.z * 50.0) -
    //                        cos((vs_Pos.x + 20.0) * (vs_Pos.y - 5.0) * (vs_Pos.z + 15.0) * 50.0));

    //fs_Nor = vec4(cross(slopey, slopex), 0.0);


//    vec4 offset = vs_Pos + vs_Nor * 0.05 * sin(vs_Pos.x * vs_Pos.y * vs_Pos.z * 50.0);
//    fs_Nor = fs_Nor * -1.0 * cos(vs_Pos.x * vs_Pos.y * vs_Pos.z * 50.0);

    normalize(fs_Nor);

    vec4 modelposition = u_Model * offset;   // Temporarily store the transformed vertex positions for use below

    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
}
