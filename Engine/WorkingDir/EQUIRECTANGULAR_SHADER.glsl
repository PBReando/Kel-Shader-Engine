#ifdef ERECT_SHADER

#if defined(VERTEX) ///////////////////////////////////////////////////

layout(location = 0) in vec3 aPosition;

out vec3 localPosition;

uniform mat4 PID;
uniform mat4 VID;

void main()
{
    localPosition = aPosition;
    gl_Position = PID * VID * vec4(aPosition, 1.0);
}

#elif defined(FRAGMENT) ///////////////////////////////////////////////

layout(location = 0) out vec4 oColor;

uniform sampler2D equirectangularMap;
in vec3 localPosition;

const vec2 invAtan = vec2(0.1591, 0.3183); 
vec2 SampleSphericalMap(vec3 v)
{
    vec2 uv = vec2 (atan (v.z, v.x), asin(v.y));
    uv *= invAtan;
    uv += 0.5;
    return uv;
}

void main()
{
    vec2 uv = SampleSphericalMap(normalize(localPosition));
    vec3 color = min(vec3(1000.0), texture(equirectangularMap, uv).rgb);
	oColor = vec4(color, 1.0);
}

#endif
#endif