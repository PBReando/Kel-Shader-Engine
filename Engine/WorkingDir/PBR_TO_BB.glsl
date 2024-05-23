#ifdef FB_TO_BB

#if defined(VERTEX) ///////////////////////////////////////////////////

layout(location = 0) in vec3 aPosition;
layout(location = 1) in vec2 aTexCoord;
//layout(location = 3) in vec3 aTangent;
//layout(location = 4) in vec3 aBitangent;

out vec2 vTexCoord;

void main()
{
	vTexCoord = aTexCoord;

	gl_Position = vec4(aPosition,1.0);
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

uniform sampler2D uAlbedo;
uniform sampler2D uNormals;
uniform sampler2D uPosition;
uniform sampler2D uViewDir;
uniform sampler2D uDepth;

uniform bool UseDepth;
uniform bool UseNormal;

layout(location = 0) out vec4 oColor;

void CalculateBlitVars(in Light light ,out vec3 ambient,out vec3 diffuse, out vec3 specular)
{
	vec3 vNormal = texture(uNormals, vTexCoord).xyz;
	vec3 vViewDir = texture(uViewDir, vTexCoord).xyz;
	vec3 lightDir = normalize(light.direction);

	float ambientStrenght = 0.2;
	ambient = ambientStrenght * light.color;

	float diff = max(dot(vNormal,lightDir),0.0f);
	diffuse = diff * light.color;

	float specularStrength = 0.1f;
	vec3 reflectDir = reflect(-lightDir, vNormal);
	vec3 normalViewDir = normalize(vViewDir);
	float spec = pow(max(dot(normalViewDir,reflectDir),0.0f),32);
	specular = specularStrength * spec * light.color;
}

void CalculateCookTorranceReflection(in Light light,out vec3 brdfColor,in vec3 normal)
{
	float normalDF =  DistributionGGX(normal);
	float F = fresnelSchlick();
	float G = GeometrySmith(normal);
}

float DistributionGGX(vec3 N, vec3 H, float roughness)
{
	float a = roughness * roughness
    float a2     = a*a;
    float NdotH  = max(dot(N, H), 0.0);
    float NdotH2 = NdotH*NdotH;
	
    float nom    = a2;
    float denom  = (NdotH2 * (a2 - 1.0) + 1.0);
    denom        = PI * denom * denom;
	
    return nom / denom;
}

float GeometrySchlickGGX(float NdotV, float k)
{
    float nom   = NdotV;
    float denom = NdotV * (1.0 - k) + k;
	
    return nom / denom;
}
  
float GeometrySmith(vec3 N, vec3 V, vec3 L, float k)
{
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx1 = GeometrySchlickGGX(NdotV, k);
    float ggx2 = GeometrySchlickGGX(NdotL, k);
	
    return ggx1 * ggx2;
}

vec3 fresnelSchlick(float cosTheta, vec3 F0)
{
    return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}

void main()
{

	vec4 textureColor = texture(uAlbedo, vTexCoord);
	vec4 finalColor = vec4(0.0);

	vec3 vViewDir = texture(uViewDir, vTexCoord).xyz;

	vec3 Halfway = normalize(vViewDir + lightDir);
	
	for(int i = 0;i< uLightCount; ++i)
	{
		
		vec3 lightResult = vec3(0.0f);
		vec3 ambient = vec3(0.0f);
		vec3 diffuse = vec3(0.0f);
		vec3 specular = vec3(0.0f);

		if(uLight[i].type == 0)
		{
			Light light = uLight[i];
			
			CalculateBlitVars(light,ambient,diffuse,specular);

			lightResult = ambient + diffuse + specular;
			finalColor += vec4(lightResult,1.0) * textureColor;
		}
		else
		{
			Light light = uLight[i];

			float constant = 1.0f;
			float linear = 0.09f;
			float quadratic = 0.032f;
			float distance = length(light.position - texture(uPosition,vTexCoord).xyz);
			float attenuation = 1.0f / (constant + linear * distance + quadratic * (distance * distance));

			CalculateBlitVars(light,ambient,diffuse,specular);
			
			lightResult = (ambient * attenuation) + (diffuse * attenuation) + (specular * attenuation);
			finalColor += vec4(lightResult,1.0) * textureColor;
		}

	}

	oColor = finalColor;

	if(UseDepth)
	{
		oColor = texture(uDepth, vTexCoord);
	}
	if(UseNormal)
	{
		oColor = texture(uNormals, vTexCoord);
	}
	
}

#endif
#endif