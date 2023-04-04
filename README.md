# Project-Ganymede

## Game overview

Our game revolves a man who's stuck on another planet with dwindling oxygen after his base malfunctions. Your goal is to move around the world and find all of the missing parts to fix the oxygen system.

The rules are simple:

Collect all of the parts, which can be found on various abandoned bases on the planet, before time runs out.
Move around with the WASD keys as well as the mouse, and pick up parts using the "E" key.
Use your special night vision lenses using the "G" key that well help you see in the dark.

## Contributions

 Bilal - terrain (height mapping), decals, reflections
 
 Karlo - windows, depth of field, LUTs, rim lighting
 
 Dilan - night vision, movement, water
 
 ## Slide deck
 
https://docs.google.com/presentation/d/1Y_jBPVpbUHKceNyb5JjRMtvUJh82EkHjuZB3_L7dPfU/edit?usp=sharing
 
 ## Report
 
 https://docs.google.com/document/d/1KyRMPiWv-_s6UiugWW5fUDkEj4chC5rc/edit?usp=sharing&ouid=114514877554687887429&rtpof=true&sd=true
 
 ## Documentation
 
### Dilan's part:

Night Vision - Using Unity's post processing stack, adding colour correction that tints the screen green and a subtle vignette. The weight of these effects are lerped either to 1 or 0 when you press the G key.

Movement - W and S to move forwards and backwards, A and D to rotate left and right, rotation can be done via mouse as well. Space to jump. 

Water - Scrolling an albedo and normal map over a plane at different speeds to give a parallax effect.

### Karlo's part:

Windows - Using a material for the wall that passes the stencil test only if the value is not equal to the refrence value, and a hole material that always passes the stencil test and replaces whatever was in the stencil buffer. Putting the hole over the wall material cuts a hole in the wall.

Depth of Field - First performs the circle of confusion pass that calculates the circle of confusion, then the pre filter pass is performed which samples the screen texture using the circle of confusion. After the bokeh pass is performed which defines the Bokeh kernel and applys the Bokeh blur onto the image. Lastly we have the post filter and combine passes which combine the effects of the previous passes into 1 image, which is then blitted onto the screen.

LUTs - LUT material samples a LUT texture and performs colour remapping based on that.

Rim Lighting - Performing the dot product between the view direction and the normals, using that as a mask to apply a rim colour.

### Bilal's part:

Terrain height mapping - Summing together several octaves of Perlin noise, each octave has an increasing frequency and decreasing amplitudes. This is done in a compute shader and sampled via a vertex and fragment shader to displace the terrain and generate normals for it.

Decals - Sampling a decal texture using the base uvs scaled and translated by user defined values and then added onto the base colour.

Reflections - Rendering a reflection probe onto a rendertexture, and then sampling the texture in a fragment shader to output as emissiveness.

## Note

The terrain generation is fairly unoptimized, therefore the build takes a few minutes to startup

## Third party resources

The lava albedo and normal maps were sourced from, https://3dtextures.me/2016/05/05/lava-002/

The decal texture for the base plaque was sourced from, https://cooltext.com/Render-Image?RenderID=433055735274831&LogoId=4330557352

The rusty metal textures (Albedo and Normal maps) were sourced from, https://polyhaven.com/a/rusty_metal_02


