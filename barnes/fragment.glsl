#version 330 core
#define SMOOTH 0

out vec4 FragColor;
in vec3 pos;


uniform float color;
vec4 color_map(float data) {
	//data -= 0.01f;
	//data = abs(data);
	if (data < 0.166f) {
		return vec4(0.0, 0.0, data * 6, 1.0f);
	}
	if (data < 0.333f) {
		return vec4(0.0, (data - 0.1666f) * 6, 1.0f, 1.0);
	}
	if (data < 0.5f) {
		return vec4(0.0, 1.0, 1.0 - (data - 0.33f) * 6, 1.0);
	}
	if (data < 0.666f) {
		return vec4((data - 0.5f) * 6, 1.0, 0.0f, 1.0);
	}
	if (data < 0.8333f) {
		return vec4(1.0, 1.0 - (data - 0.66f) * 6, 0.0, 1.0);
	}
	if (data < 1.0f) {
		return vec4(1.0 - (data - 0.833f) * 6, 0.0f, 0.0, 1.0);
	}
	return vec4(1, 1, 1, 1);
}
void main()
{
	
	FragColor = pos.y >= 0 ? color_map(pos.y * 0.005f + 0.1f) : vec4(0, 1, 1, 0);
}