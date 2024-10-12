#version 460 core
layout(location = 0) in vec3 aPos;
out vec3 pos;

uniform float scale = 1.0f;
uniform float x = 0.0f;
uniform float y = 0.0f;

layout(std430, binding = 1) buffer rx
{
	float datax[];
};
layout(std430, binding = 2) buffer ry
{
	float datay[];
};
layout(std430, binding = 3) buffer rz
{
	float dataz[];
};
void main() {
	gl_Position = vec4(2*(datax[gl_VertexID]*0.0625f/32   - 0.5f), 2*( - datay[gl_VertexID] * 0.0625f/32  + 0.5f), 0, 1.0);
	pos = vec3(1, dataz[gl_VertexID], 0);/// color_map(lininterp(data[gl_VertexID]));
}
