#ifdef SKYBOX_SHADER

#if defined(VERTEX) ///////////////////////////////////////////////////

layout(location = 0) in vec3 aPosition;


layout(binding = 0,std140) uniform GlobalParams
{
	vec3 uCameraPosition;
	uint uLightCount;
	Light uLight[16];
};

layout(binding = 1, std140) uniform LocalParams
{
	mat4 uWorldMatrix;
	mat4 uWorldViewProjectionMatrix;
};

out vec3 vTexCoords;


void main()
{

}

#elif defined(FRAGMENT) ///////////////////////////////////////////////


in vec3 TexCoords;
uniform sampler2D uTexture;
layout(location = 0) out vec4 oColor;


void main()
{
	oColor = fragPos;
}

#endif
#endif