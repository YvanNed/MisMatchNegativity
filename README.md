# MisMatchNegativity
Passive MMN task based on duration.

THIS BRANCH HAS A WEBER LIKE DISTRIBUTION OF DEV (+/- 5, 10, 15%) WITH A NBR OF STD OF 2400 (80%) AND A NBR OF EACH DEV OF 100 (3.333%)


This repository contains:
  - Matlab code #MMN_duration_XXX# to run the MMN task, depending on the branch, in:
    - laboratory
    - train 
    Using EEG (change the triggers code):
      - BrainProduct (LiveAmp) 
      - AntNeuro (EEGO)
  - Matlab code #GenerateSounds_Y# to create empty sounds (two burst of 5ms white noisedelimit the sound) of different duration. Those sounds are not used anymore, the 5ms burst are created in the task now to allow a better control for timing 
  - Matlab code #mkTimeKeeperSpeak# too check the timing in our task
  - Directory #SOUNDS# containing the sounds use in the task
  - Directory #RESULTS# where the experimental Matrices will be saved 
