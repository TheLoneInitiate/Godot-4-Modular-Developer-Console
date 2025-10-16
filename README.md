# Modular Developer Console for Godot 4.x

_**A simple and effective in-game console designed for easily adding or removing new console commands. Our modular approach will suit all your needs.**_  
  
## Features
- **Toggleable Console**: Open/close with the backtick (`) key.
- **Command System**: Modular commands stored as GDScript files in `res://Addons/ModularDevConsole/commands/`.
- **Tab Completion**: Autocomplete commands and arguments (e.g., node names, scene names).
- **Command History**: Navigate previous commands with Up/Down arrow keys.
- **Logging**: Optional auto-saving of console output to logs in `user://modular_dev_console_logs/`.
- **Authentication**: Secure commands with `rcon_password` for sensitive operations.
- **Scene Tree Inspection**: View and navigate the scene tree with `rcon_tree`.
- **Debug Visuals**: Toggle visibility for collision shapes, raycasts, and tilemap grids.
- **Script Execution**: Run custom GDScript files with `exec`.
- **Node Manipulation**: Inspect and modify node properties and call methods dynamically.

## Usage
- **Open Console**: Press the backtick (`) key to toggle the console.
- **Enter Commands**: Type a command and press Enter to execute.
- **Navigate History**: Use Up/Down arrow keys to cycle through command history.
- **Tab Completion**: Press Tab to autocomplete commands or arguments.
- **Scroll Output**: Use mouse wheel to scroll through console output.
- **Secure Commands**: Use `rcon_password <password>` to authenticate for restricted commands (default password: `gaben`).
- **Cancel Selection**: Press Escape to cancel node selection in `rcon_tree`.

| Command | Description | Usage | Notes |
|---------|-------------|-------|-------|
| `call` | Calls a method on a node with optional arguments. | `call <node_name_or_path> <method_name> [args...]` | Supports up to 3 arguments; closes console on success. |
| `clear` | Clears the console output. | `clear` | Simple command to reset the output display. |
| `debug_collision` | Toggles visibility of collision shapes for a node or all nodes. | `debug_collision <all | node_name>` | Visualizes 2D/3D collision shapes in green (on) or removes them (off). |
| `debug_grid` | Toggles a debug grid overlay on a `TileMapLayer`. | `toggle_grid [on|off|toggle]` | Draws a white grid over the visible tilemap area; requires a `TileMapLayer` and active `Camera2D`. |
| `debug_raycast` | Toggles visibility of raycasts for a node or all nodes. | `toggle_raycasts <all | node_name>` | Visualizes rays as yellow (no collision) or red (collision); updates in real-time. |
| `exec` | Executes a GDScript file from `res://Scripts/`. | `exec <filename> [args...]` | Runs `run()` method if present; supports `.gd` extension omission. |
| `exit` | Closes the game. | `exit` | Terminates the application. |
| `inspect` | Displays details about a node (path, parent, position, children, etc.). | `inspect <node_name>` | Shows properties like position, rotation, and custom attributes (e.g., `speed`, `health`). |
| `list_groups` | Lists groups a node belongs to. | `list_groups <node_name>` | Outputs all groups for the specified node. |
| `load_scene` | Loads a scene from `res://scenes/`. | `load_scene <scene_name>` | Lists available scenes if no name provided; requires `.tscn` files. |
| `print_vars` | Prints exported variables of a node. | `print_vars <node_name>` | Requires `rcon_password` authentication. |
| `rcon_password` | Authenticates for restricted commands. | `rcon_password <password>` | Default password: `gaben`. |
| `rcon_tree` | Displays the scene tree and allows subtree inspection. | `rcon_tree` | Requires authentication; enter node index to view subtrees, Escape to cancel. |
| `reload` | Reloads the current scene. | `reload` | Requires authentication. |
| `save_log` | Saves console output to a log file. | `save_log [filename]` | Saves to `user://modular_dev_console_logs/`; defaults to timestamped filename. |
| `profile` | Manages performance profiling and tile counts. | `profile <on|off|stats|tiles> [chunk_x chunk_y]` | Toggles performance HUD, shows memory/draw calls, or counts tiles by type/group. |

### Adding Custom Commands
1. Create a new GDScript in `res://Addons/ModularDevConsole/commands/` (e.g., `my_command.gd`).
2. Extend `Node` and implement a `run(args: Array)` method:
   ```gdscript
   extends Node
   var console: Node
   func run(args: Array) -> void:
       console.add_output("My custom command with args: " + str(args))
  
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

**- debug_collision < nodename > or < all >**
Toggles a custom draw for collision shapes of 2D and 3D objects.
Support 2 arguments for all nodes or specific node

**- debug_raycast < nodename > or < all >**
Draws raycasts within a node and changes color when its colliding.
Support 2 arguments for all nodes or specific node

**- list_groups** 
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

**- Perf**
_Displays performance stats_
  
  
**Contact info :**  
Discord ID : theloneinitiate  
  
Willing to entertain new command ideas if you have any just let me know on discord
Please also report bugs to me on discord



# Installation Details

Add extract the addons folder into the root res:// directory.
It will then automatically set the console.tscn as an autoload singleton in your project settings.
To test it, launch your project and use the ` key to open the console.

If you get an annoying warning about console.tscn uid, just go to addons/ModularDevConsole/ and open the console.tscn then cntrl+s save and reload the project. It will stop giving the warning.

Make sure the following directory paths exists :
res://addons/ModularDevConsole/logs
res://addons/ModularDevConsole/commands
res://scenes

If you're having issues, make sure to check for capital letters in the directory listings.
all the directories use lowercase letters.


To enable and disable auto save / auto load console logs you will need to edit the boolean in the main console.gd file.
It's all very organized and easy to deal with.
