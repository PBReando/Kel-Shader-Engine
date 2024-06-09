#ifdef RENDER_TO_FB

#if defined(VERTEX) ///////////////////////////////////////////////////

layout(location = 0) in vec3 aPosition;
layout(location = 1) in vec3 aNormal;
layout(location = 2) in vec2 aTexCoord;

struct Light
{
	uint type;
	vec3 color;
	vec3 direction;
	vec3 position;
};

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

out vec2 vTexCoord;
out vec3 vPosition; // in worldspace
out vec3 vNormal;  // in worldspace
out vec3 vViewDir;

void main()
{
	vTexCoord = aTexCoord;

	vPosition = vec3(uWorldMatrix * vec4(aPosition,1.0));
	vNormal = vec3(uWorldMatrix * vec4(aNormal,0.0));
	vViewDir = uCameraPosition - vPosition;
	float clippingScale = 1.0;

	gl_Position = uWorldViewProjectionMatrix * vec4(aPosition, clippingScale);
}

#elif defined(FRAGMENT) ///////////////////////////////////////////////

struct Light
{
	uint type;
	vec3 color;
	vec3 direction;
	vec3 position;
};

layout(binding = 0,std140) uniform GlobalParams
{
	vec3 uCameraPosition;
	uint uLightCount;
	Light uLight[16];
};

in vec2 vTexCoord;
in vec3 vPosition; // in worldspace
in vec3 vNormal;  // in worldspace
in vec3 vViewDir;

uniform sampler2D uAlbedo;
uniform sampler2D uRoughness;
uniform sampler2D uEmissive;
uniform sampler2D uAmbientOclusion;
uniform sampler2D uMetallic;

layout(location = 0) out vec4 oAlbedo;
layout(location = 1) out vec4 oNormals;
layout(location = 2) out vec4 oPosition;
layout(location = 3) out vec4 oViewDir;
layout(location = 4) out vec4 oRoughness;
layout(location = 5) out vec4 oEmissive;
layout(location = 6) out vec4 oAmbientOclusion;
layout(location = 7) out vec4 oMetallic;


void main()
{

	oAlbedo = texture(uAlbedo,vTexCoord);
	oNormals = vec4(vNormal,1.0);
	oPosition = vec4(vPosition,1.0);
	oViewDir = vec4(vViewDir,1.0);
	oRoughness = vec4(vec3(texture(uRoughness,vTexCoord).r), 1.0f);
	oEmissive = vec4(texture(uEmissive,vTexCoord).xyz, 1.0f);
	oAmbientOclusion = vec4(vec3(texture(uAmbientOclusion,vTexCoord).r), 1.0f);
	oMetallic = vec4(vec3(texture(uMetallic,vTexCoord).r), 1.0f);

}

#endif
#endif