# Project-Ganymede

Link to slides:
https://docs.google.com/presentation/d/1BPtmmhs6PKpX6A1nvFb_5S8pmELzzYACPNVoMmbV_mw/edit?usp=sharing

Link to demo video:
https://drive.google.com/file/d/1_byoUF5gKyCOTuYOm0wTW1DftF5q8o02/view?usp=share_link

Link to explanation docs:
https://docs.google.com/document/d/1V-HtQNBMrB6vGilN72SYCoyiGUeBZb8JO-7TT6d7bIw/edit?usp=sharing


NOTE: Since I am doing a written report, some of the information on here, the slides and the docs will be redundant. I will try to make it a different as possible by putting the "design choices" here, the coding and technical explanation in the docs and extra stuff on the slides (mostly just a shorter rewrite of the thngs on the docs).

Credits:

FOV code taken from:
https://www.youtube.com/watch?v=rQG9aUWarwE
I am not a programmer, nor do I plan to be in the future.
While I did do everything else myself, the FOV script was a bit too complicated for myself to do, hoever I did try to understand the code.
I kept all of the variables and everything else the same to all the code as original as possible (to avoid making it look like I took the code and tried covering it up).

Movement code taken from:
Dilan Mian.
He is also my teammate in the group assignment; his role was to make the movement system for our game.
I used his code for the individual assignment (with permission of course).
The only thing I changed from his code to fit my requirements was to remove the death plane and lose condition on contact with that plane (since my player shouldn't be able to fall off the world).



Base
- [X] Movement
- [X] Scene
- [X] Moving objects
- [X] Win/lose

2 Lighting shaders
- [X] Lambert
- [X] Simple diffuse
- [X] Toggle

LUT
- [X] 3 LUTs
- [X] Togglable LUT shaders

2 Additional shaders
- [X] Reflection probe
- [X] Rim lighting

Video (written report in my case because of technical problems)
- [X] Explanation document
- [X] Google slides



Explanations behind what I did:

Base:
My task for the project for our group assignment was to make an item pickup system, so I decided to build around to be able to progress on my group task while also finishing the individual assignment. Since there was a win/lose condition requirement, I turned my pickup system into a timed item scavenging challenge by adding a timer and a set list of items; If you collect all items, you win, if the timer runs out, you lose. I chose a blueish and dark scene/skybox to represent the theme of our group game, which is that of being stuck on another planet far away in space.

2 Lighting shaders:
I chose lambert and simple diffuse as my two lighting shaders. I applied those onto the walls with a toggle option (keys 1 and 2 switch between the two) as a sort of "High/Low quality" option where the lambert lighting looked like a way lower quality shader.

LUT:
The first two LUTs were the requested warm and cold colour changes, the third and custom one was meant to give a darker, colder and more lonely feel to make it feel like the player was truly alone in the vastness of space. The shader script can be toggled on and off using the 7 key and the warm, cold and custom LUTs can be selected by using the 8, 9 and 0 keys, in that order.

2 Additional Shaders:
I chose reflection probes and rim lighting as my two additional shaders. I added a reflection probe onto the floor to give the scene a more surreal look by reflecting the blue moon onto the floor.
(NOTE: The reflection probe did not fully work as intended, further explanations will be given in the written report and the slides)
I gave the items a default metallic material (since the items in our game are most likely going to be made of some sort of metal) and made it so that if the player looks at the object, they will switch over to rim lighting to make it look like it's being selected. I also made the shader increase and decrease in "rim power" to give it a more dynamic feel, sort of like you would see in many other games of this sort.