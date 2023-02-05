# Project-Ganymede

## Illumination
- Simple diffuse with ambient, taking the dot product between the light direction and face normal, this tells us how "similar" these 2 vectors are, the more similar they are, the more diffuse lighting we add, ambient is simply a base light done so we don't have harsh black shadows. The scene benefits from this because it makes the geometry feel 3D
- Fog shader, using the depth buffer to figure out how far a fragment is away from the camera, based on that distance we use an exponential squared falloff to occlude the geometry with a fog colour. This effect makes the scene feel a lot bigger than it actually is, makes the horizon feel far away
## Colour Grading
- 3 LUT profiles, warm, cool, and cinematic. These just remap colours from each fragment to colours defined in the LUTs, the strength of this remapping can be configured. The key modification I made to lecture code was allowing for LUT switching without creating multiple materials. These effects allow us to change the tone of the scene so it fits the game a lot better
## Additional Shaders
- Height mapping, using several octaves of perlin noise summed together to displace the geometry, each octave has a lower amplitude and a higher frequency than the last, this prevents the terrain from looking like incoherent noise (just made up of giant spikes everywhere), while adding details. The noise is calculated via world space coordinates as well, so the terrain can tile. The project benefits from this a lot because it allows us to create terrain at runtime that's random
- Tessellation, used to implement a custom LOD system, where far away geometry has less verticies than close up geometry. Just done by generating tesselation factors based on a tesselation control point's distance to the camera. The project benefits from this because it lets us have very detailed terrain without needing to compromise speed
## Extras
- Chunk system, Just instantiating chunks around the player based on a render distance and chunk size. If the player gets too far away from the center of all the chunks, then old chunks are deleted and new chunks are calculated around the player. This benefits our scene a lot because there's a limit to how much tesselation can be done on 1 plane, so we need to have multiple in order to cover a large area and have it be detailed
## Supporting items
- Slide deck, https://docs.google.com/presentation/d/1jp4cjNGeyvY5ELHTbv_oYAgseg-nTH5iphQWT-3yax4/edit?usp=sharing
- Video, https://www.youtube.com/watch?v=xMY1GLC9shI
