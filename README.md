# Modular Developer Console for Godot 4.x

_**A simple and effective in-game console designed for easily adding or removing new console commands. Our modular approach will suit all your needs.**_  
  
**Default toggle key : " ~ "**  
  
The main console script `res://scripts/console.gd` scans a commands folder which holds a separate script file for each individual command. Making it extremely easy to add or remove commands without needing to modify the main console script.  
![enter image description here](https://i.imgur.com/74pd5M1.png)
  
**Here's an example script of the exit command for closing your game**
![enter image description here](https://i.imgur.com/CqmVf3W.png)
  
To add a new command just create a new script file in the /scripts/console/commands/ directory and put your functionality in the func run command.  
It's as simple as that.  
  
Here's a list of already existing commands that come with this project as of now :  
  

 **- rcon_password** **<password>**
Can be used to require additional privilege for specific commands.  
To require password authentication for a command just start the run function with an if statement 
( See Image below )_  
![enter image description here](https://i.imgur.com/DeL3t9F.png)

  
**- rcon_tree**
_Lists all nodes in the scene tree as an array._
_Type the array number of the node you want to inspect further._  

**- print_vars**
_Lists all variables of a specific node (e.g : print_vars player )_

**- set**
_Set a property value to any node (e.g : set player speed 500.0 )_

**- inspect**
Get inspector info on any ;node in the scene (e.g : see screenshots )

**-list_groups** 
_displays list of groups of a specific node_

**- exec**
_execute any script on command_ _inside of directory : /scripts/executable/example.gd_

 **- load_scene**
_load any scene inside res://scenes/ directory_ _(e.g : load scene02 )_  

**- reload**
_reloads current scene_  

 **- save_log**
_saves console output to a log file inside of res://logs/_

 **- load_log**
_loads log into current console output._
_You can also enable auto save and auto load in the main console.gd file._

 **- clear**
_clears the console output to be empty_  

 **- exit**
_closes the game with get_tree().quit()_

**- help**
_displays a list of all commands and their descriptions_  

**= Perf**
_Displays performance stats_
  
  
**Contact info :**  
Discord ID : theloneinitiate  
  
Willing to entertain new command ideas if you have any just let me know on discord
Please also report bugs to me on discord



# Installation Details

add console.tscn to project settings -> autoload

Make sure the following directory paths exists :
res://logs
res://scenes
res://scripts/console
res://scripts/console/commands



To enable and disable auto save / auto load console logs you will need to edit the boolean in the main console.gd file.
It's all very organized and easy to deal with.
