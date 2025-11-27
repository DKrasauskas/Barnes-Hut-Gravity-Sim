#version 460 core
layout(location = 0) in vec3 aPos;
out vec3 pos;

uniform float scale = 1.0f;
uniform float x = 0.0f;
uniform float y = 0.0f;
layout(std430, binding = 3) buffer rx
{
	float datax[];
};
layout(std430, binding = 4) buffer ry
{
	float datay[];
};
layout(std430, binding = 5) buffer rz
{
	float dataz[];
};
void main() {
	uint id = gl_VertexID / 4;
	gl_Position = vec4(2.0f * dataz[id] * (aPos.x - 0.5f)  +2.0f*(datax[id] - .5f), 2.0f * dataz[id] * (aPos.y - 0.5f) + 2.0f * (-datay[id] + .5f), 0, 1.0);
	pos = vec3(0, -1, 0);/// color_map(lininterp(data[gl_VertexID]));
}
/*unsigned int key = datax[gl_VertexID];
float scale = 1.0f;
int d;
for (int i = 0; i < 8; i++) {
	d = i;
	if (depth[i] & key != 0) {
		key ^= depth[i];
		break;
	}
	scale *= 0.5f;
}
int x = 0;
int y = 0;
for (int i = 0; i < 32; i += 2) {
	int bitX = (key[idx] & ((uint32_t)1));
	key[idx] = key[idx] >> 1;
	int bitY = (key[idx] & ((uint32_t)1));
	key[idx] = key[idx] >> 1;
	x |= bitX << i / 2;
	y |= bitY << i / 2;
}
float x1 = (x - 1) * scale;*/
//float y1 = (y - 1) * scale;