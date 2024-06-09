#ifdef SKYBOX_SHADER

#if defined(VERTEX) ///////////////////////////////////////////////////

layout(location = 0) in vec3 aPosition;

out vec3 vTexCoords;

uniform mat4 PID;
uniform mat4 VID;

void main()
{
    vTexCoords = aPosition;
    gl_Position = PID * VID * vec4(aPosition, 1.0);
}

#elif defined(FRAGMENT) ///////////////////////////////////////////////

layout(location = 0) out vec4 oColor;

uniform samplerCube skybox;
in vec3 vTexCoords;

void main()
{
     oColor = texture(skybox, vTexCoords);
}

#endif
#endif