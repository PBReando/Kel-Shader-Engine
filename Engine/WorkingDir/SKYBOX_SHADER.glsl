#ifdef SKYBOX_SHADER

#if defined(VERTEX) ///////////////////////////////////////////////////

layout(location = 0) in vec3 aPosition;

out vec3 vTexCoords;

uniform mat4 projection;
uniform mat4 view;

void main()
{
    TexCoords = aPos;
    gl_Position = projection * view * vec4(aPosition, 1.0);
}

#elif defined(FRAGMENT) ///////////////////////////////////////////////

layout(location = 0) out vec4 oColor;

uniform samplerCube skybox;
in vec3 TexCoords;

void main()
{
	 oColor = texture(skybox, TexCoords);
}

#endif
#endif