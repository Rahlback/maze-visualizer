# Maze visualizer
This repo contains the program to visualize the mazes from [this repository](https://github.com/CodeForest-lab/micromouse-coding-challenge)

It was made using Godot 4.6

# Running
There are two ways to run the program
- Loading the project into [Godot](https://godotengine.org/)
- Unzipping the zip file in the build folder and running the executable
	- The pck file needs to be next to the exe file when running


# Controls
Pressing the ESC key - Show / hide controls

Reverse button - Slow down animation

Play button - Start animations

Pause button - Pause animations

Forward button - Speed up animation

Load maps - Select which map data to show and animate

# Expected format of map data
The expected folder structure is as follows:
- folder_maze
  - map.txt
  - team_teamname.txt
  - team_teamname2.txt
  - team_teamname3.txt
  - team_teamnameN.txt

There can be an infinite number of teams, but eventually the UI will overflow
