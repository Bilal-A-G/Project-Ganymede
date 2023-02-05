# Project-Ganymede

Demo Vid: 
https://www.youtube.com/watch?v=WS-_jDQjFjw

Slide Deck:
https://docs.google.com/presentation/d/1EvMhJOyCefCWRpnjK4OlM2DszUK_RsiOIxa8WTRALPM/edit?usp=sharing


Explanation: I used shader code derived from templates that were previously used in our lectures and labs
to build a simple specular shader, a toon ramp, LUTs, as well as grain effect and normal mapping using other tools.
I created a simple first-person platform jumping simulation. I did this since my group's final project will involve
this type of exploration of a space-themed environment, therefore this aspect of the game is crucial. The Simple Specular
and Toon Ramp work by having their own respective and necessary shader code classes attached to different materials,
then they were indvidually attached to a script that toggles between them. This script is attached to the walls and platforms
in the scene. Then the LUTs were created similarly with a standard LUT appropiate shader script for each of the 3 with their 
own LUTs created in Photoshop to mathc different filters. The LUTs as well as the respective scripts were attached to different
materials. Then these materials could be toggled in their own script while being attached to the camera so that we can see
them each as soon as the game starts. Then the grain effect was made using a post processor tool that has a function
of creating film grain with a configurable level of intensity. Then this post processor was attached to a separate child
attached to the player. The child object has a specific layer for the film grain effect. Then the camera has a post 
processor reference component with the same layer of the film grain. This allows the effect to happen as soon as the 
scene starts. Lastly the normal mapping was used with an imported normal map appropriate wall texture that was attached
in turn to a material in its normal mapping designated section. And from there the texture was attached to the walls
and platforms, and the normal mapping can be toggled with the other shaders I've mentioned previously. These additions
benefit the project by not only conforming to the project requirements but also demonstrate different ways of making
our game more exciting and aesthetically appealing. 



