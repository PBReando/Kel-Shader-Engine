#ifdef PBR_TO_BB

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

const float PI = 3.1415926535897;

uniform sampler2D uAlbedo;
uniform sampler2D uNormals;
uniform sampler2D uPosition;
uniform sampler2D uViewDir;
uniform sampler2D uRoughness;
uniform sampler2D uEmissive;
uniform sampler2D uAmbientOclusion;
uniform sampler2D uMetallic;
uniform sampler2D uDepth;

uniform bool UseDepth;
uniform bool UseNormal;

layout(location = 0) out vec4 oColor;

float DistributionGGX(vec3 N, vec3 H, float roughness)
{
	float a = roughness * roughness;
    float a2     = a*a;
    float NdotH  = max(dot(N, H), 0.0);
    float NdotH2 = NdotH*NdotH;
	
    float nom    = a2;
    float denom  = (NdotH2 * (a2 - 1.0) + 1.0);
    denom        = PI * denom * denom;
	
    return nom / denom;
}

float GeometrySchlickGGX(float NdotV, float roughness)
{
    float r = (roughness + 1.0);
    float k = (r*r) / 8.0;

    float num   = NdotV;
    float denom = NdotV * (1.0 - k) + k;
	
    return num / denom;
}
  
float GeometrySmith(vec3 N, vec3 V, vec3 L, float roughness)
{
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx1 = GeometrySchlickGGX(NdotV, roughness);
    float ggx2 = GeometrySchlickGGX(NdotL, roughness);
	
    return ggx1 * ggx2;
}

vec3 fresnelSchlick(float cosTheta, vec3 F0)
{
    return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}

vec3 PBRLighting(vec3 V,vec3 N,vec3 H,vec3 L,vec3 albedoColor,vec3 radiance,float roughness,float metallic)
{
	vec3 F0 = vec3(0.56,0.57,0.58);
	float _cosTheta = max(dot(V,H),0.0);
	vec3 Ks = fresnelSchlick(_cosTheta,F0);
	vec3 Kd = vec3(1.0) - Ks;

	vec3 lambert = albedoColor / PI;

	vec3 cookTorranceNumerator = DistributionGGX(N,H,roughness) * GeometrySmith(N,V,L,roughness) * Ks;
	float cookTorranceDenominator = 4.0 * max(dot(V,N),0.0) * max(dot(L,N),0.0) +0.0001;
	cookTorranceDenominator = max(cookTorranceDenominator,0.000001);
	vec3 specular = cookTorranceNumerator / cookTorranceDenominator;

	Kd *= 1.0 -metallic;

	vec3 BRDF = Kd * lambert + specular;

	vec3 lightOut = BRDF * radiance *max(dot(L,N),0.0);

	return lightOut;
}

void main()
{
	vec3 fragmentPosition = texture(uPosition, vTexCoord).rgb;
	vec3 vNormal = texture(uNormals, vTexCoord).rgb;
	vec3 N = normalize(vNormal);
	float roughness = texture(uRoughness, vTexCoord).r;
	float metallic = texture(uMetallic, vTexCoord).r;
	float ambientOclusion = texture(uAmbientOclusion, vTexCoord).r;
	vec3 emissive = texture(uEmissive, vTexCoord).rgb;

	vec3 albedoColor = texture(uAlbedo, vTexCoord).rgb;
	vec4 finalColor = vec4(0.0);

	vec3 vViewDir = texture(uViewDir, vTexCoord).rgb;
	vec3 V = normalize(vViewDir);
	vec3 lightDir = vec3(0.0);

	vec3 Halfway = vec3(0.0);
	
	vec3 LightsAfterPBR = vec3(0.0);
	vec3 _lightIntensity = vec3(0.0);

	for(int i = 0;i< uLightCount; ++i)
	{
		
		Light light = uLight[i];

		vec3 lightColor = light.color;
		
		if(light.type == 0)
		{	
			//Directional
			lightDir = normalize(light.position);
			_lightIntensity = light.color * 5.0;
		}
		else
		{
			//Point
			lightDir = normalize(light.position - fragmentPosition);
			float distance = length(light.position - fragmentPosition);
			float constant = 1.0f;
			float linear = 0.09f;
			float quadratic = 0.032f;
			float attenuation = 1.0f / (constant + linear * distance + quadratic * (distance * distance));
			_lightIntensity = light.color * (5.0 * attenuation);
		}
		Halfway = normalize(V + lightDir);

		LightsAfterPBR += PBRLighting(V,N,Halfway,lightDir,albedoColor,_lightIntensity,roughness,metallic);		

	}

	vec3 ambientLight = vec3(0.03) * albedoColor * ambientOclusion;

	vec3 _color = ambientLight + LightsAfterPBR;


	oColor = vec4(_color,1.0);
}

#endif
#endif