#pragma once

const unsigned int SCR_WIDTH = 1200;
const unsigned int SCR_HEIGHT = 1200;


#define D_MAX  9
#define N_DIM  512
#define OUT 1 // 1 to write output to mp4
#define phi 1.0f
#define G 100.0f

//globals
GLFWwindow* window;
int stateS = 0;

void processInput(GLFWwindow* window)
{
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);  
    if (glfwGetKey(window, GLFW_KEY_E) == GLFW_PRESS)
        p += 1;
    if (glfwGetKey(window, GLFW_KEY_Q) == GLFW_PRESS)
        p -= 1;
    if (glfwGetKey(window, GLFW_KEY_P) == GLFW_PRESS)
        stateS += 1;
    if (glfwGetKey(window, GLFW_KEY_L) == GLFW_PRESS)
        stateS -= 1;
}