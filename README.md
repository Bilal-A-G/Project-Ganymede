# Project-Ganymede

## Game overview

Our game revolves a man who's stuck on another planet after having his spaceship malfunction and crash-land. Your goal is to move around the world and find all of the missing parts of the ship.
The rules are simple:
Collect all of the ship parts and return back to the ship before time runs out.
Move around with the arrow keys as well as the mouse, and pick up parts using the "E" key.
Use your special x-ray lens using the "Z" key that well help you see through certain obstacles at the cost of some visibility.

## Contributions

 Bilal - terrain, fog, outline, shadows, decals
 
 Karlo - win condition, simple diffuse, window effect, vignette
 
 Dilan - win condition, LUTs, film grain, bloom, lens flare
 
 ## Slide deck
 
 https://docs.google.com/presentation/d/1Tmz6tGJAW_vvRs1tdqO0kRogqy_PfAdK71qlLbz7Ydo/edit?usp=sharing
 
 ## Video
 
 https://youtu.be/-wZvO_f2QXc
 
 ## Documentation
 
### Dilan's part:

Basically, for my part, we combined my previous creations in the Individual Assignment, and then was left with some new tasks to complete for this final assignment. They were a bloom effect for the camera as well as a lens flare effect in accordance with the directional light and its relation to the player's position. I added in the bloom effect by editing the previous post processing effect with the film grain by adding the new effect of the bloom into the same post processing layer for the camera. From there both could appear at the same time. Along with this the lens flare effect was created by adding a Unity flare gameobject with set conditions such as varying levels of intensity, color, and size. This flare object was then neatly added to the Light component of the Directional Light's Inspector, specifcally the lens flare placeholder.

### Karlo's part:

The two effects that I chose to do were:
The stencils for the shader part and a vignette effect on the camera for the post processing effect.

For the stencil effect, I chose to reuse the code and method learned in class. The relevant parts of code were of course commented out to show comprehension.
The “Wall Stencil” shader script is a basic lighting shader script. The only change is that a segment needs to be added before CGPROGRAM.
Same with the “Hole Stencil” script, although this one is a little more complicated.
The wall stencil was put on a wall object while the hole stencil went on a simple quad to give it the window effect.
I also created a simple moving script called “QuadMove” that would move the quads left to right at a sinusoidal speed.

For the vignette effect, I created a vertex/fragment shader script called “Vignette” with the help of CHATGPT for a few of the segments.
Start the program, create the vertex and fragment structs and create the variable for them, and then define the previously created variables.
Finally, create the vertex and fragment methods.
Since this effect, was put on the camera, the “VignetteCam” C# script was also created using the same concept used in class during the LUT task.
Finally, I created an C# script called “VignettePulse” that would change the intensity of the effect at the press of a button to make it look like it’s being turned on and off. 
If the “Z” key is pressed, activate or deactivate the effect as well as allow it to go through it’s full transition effect.

If the effect is “on” and the effect hasn’t gone through its full transition yet, change the vignette intensity value using an animation curve.
If it is off, do the same thing, but reverse “time += Time.smootheDeltaTime” to “time -= Time.smootheDeltaTime” to make the effect retract instead of expand.

In both cases, if the transition is finished, turn “transition” to false to prevent “time” from going past its boundaries.


The animation curve lerp segment is the same as the one used in the “BallSwitch” script (for the rim lighting effect). The only main difference is that the curve is set to clamp and not ping pong.
This would give the effect a smooth transition between the on and off states to make it look like a lens being pulled away.
I changed the “Switch” script to make it so that when the player activates the vignette effect (which acts as a lens), it will also turn on the stencils, making it feel like a special x-ray vision ability.

### Bilal's part:

Shadows - Using a shadowcaster pass to cast shadows onto other objects, and adding shadow colour onto the output colour to recieve shadows

Outline - Extruding the mesh outwards (in a seperate pass) using it's screen space projected normals and a outline width, using culling to prevent the interior from being seen

Decals - Sampling a decal texture using the base uvs scaled and translated by user defined values and then added onto the base colour
