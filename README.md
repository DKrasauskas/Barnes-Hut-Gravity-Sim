![image](https://github.com/user-attachments/assets/0cbf49c2-07a7-4fa0-9dda-36b9f6e26e84)

Barnes-Hut gravity simulation utilizing a GPU based Quad-Tree. Written using Cuda and Thrust.
Tree construction on GPU was implemented based on the paper by J. Zhang and L. Gruenwald (https://adms-conf.org/2019-camera-ready/zhang_adms19.pdf) with some minor modifications.
The bottleneck of the simulation is the acceleration computation for the particles, as the tree construction step tends to be really fast. 


https://github.com/user-attachments/assets/6690395c-04b0-4d9b-9326-5763cbf6f1f4

