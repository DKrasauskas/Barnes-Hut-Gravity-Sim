#pragma once
#include "../../../../../../usr/lib/gcc/x86_64-pc-linux-gnu/14.3.1/include/c++/iostream"
#include "../../../../../../usr/lib/gcc/x86_64-pc-linux-gnu/14.3.1/include/c++/string"
#include "../../../../../../usr/lib/gcc/x86_64-pc-linux-gnu/14.3.1/include/c++/fstream"
#include"../../../../../../usr/lib/gcc/x86_64-pc-linux-gnu/14.3.1/include/c++/sstream"
#include "glad.h"
#include "glfw3.h"



using namespace std;

class Shader {
public:
    unsigned int ID;
    Shader(const char* inputVertex, const char* inputFragment);
    ~Shader();
    char* Parse(string input);
    void BuildShaders(unsigned int& shader, const char* source, uint32_t shader_type);
    void Link(unsigned int& program);
};
class Cshader {
public:
    unsigned int ID;
    Cshader(const char* inputCompute);
    ~Cshader();
    char* Parse(string input);
    void BuildShaders(unsigned int& shader, const char* source, uint32_t shader_type);
    void Link(unsigned int& program);
};