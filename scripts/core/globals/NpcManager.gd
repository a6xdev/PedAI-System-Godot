extends Node

var PedSpawnerControllerNode:PedSpawnerController = null

var all_peds:Array[actor_npc] = []
var inactive_peds:Array[actor_npc] = []
var active_peds:Array[actor_npc] = []

# ALERT: It isnt the best way to do it, mainly in a big open world because of the streaming of many chunks, objects and etc.
# but for this project it will do the job. A good solution would be get the actions in the Chunk System.
var smart_objects:Array[SmartObjects] = []
