# Spaceship Two-Step Sequential Learning Task (AN Compatible)
This is an adaptation of Nathaniel Daw's two-step decision making task.

- Author: Alexander Breslav (Duke)
- Collaborators: Lucy Gallop (KCL), Dr. Scott Huettel (Duke), Dr. Nancy Zucker (Duke), Dr. John Pearson (Duke)
- Original code and stimuli were generously shared by Dr. Arkady Konovalov (UZH) [[citation]](https://www.nature.com/articles/ncomms12438?origin=ppub) and Dr. Catherine Hartley (NYU) [[citation]](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4899156/).

This version of the task uses spaceships/aliens stimuli and is designed for teenagers and adults.
I have made a number of major changes for the purposes of my work:

For this version of the task:
 - I overhauled the tutorial to ensure that participants could understand the rules and complex dynamics of the game. The new design is based on prior qualitative testing of the task tutorial, as well as feedback from multiple clinical psychologists that specialize in cognitive development.

- I created higher quality stimuli and expanded the stimuli set. This was done so that each block (practice, food, and money blocks) had entirely different stimuli and the stimuli colors/shapes could be randomized between subjects. The stimuli color pairs are all accessible.

- There are practice rounds and two blocks of 150 trials. During both blocks, participants try to win as much space treasure as possible. At the end of both blocks, participants receive a random monetary reward and food item from an array of possible items. The number of items in the array and the items in the array is determined by their performance on that block.

- The task utilizes Qualtrics to capture wanting ratings as well as reveal the results at the end of the study. The entire experimental package is not currently on GitHub. If you would like to run this version of the study, please contact me.

Dependencies:
- MatLab
 - MatLab 9.4
 - Psychtoolbox 3
 - Statistics and Machine Learning Toolbox 11.3
- Other
 - Qualtrics
 - Python
  - Pandas, Numpy, requests, json, sys, base64, datetime, webbrowser
Please do not share or use this code without my written consent.  
alexander.breslav@duke.edu
