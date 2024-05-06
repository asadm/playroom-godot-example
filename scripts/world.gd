extends Node2D
var Playroom = JavaScriptBridge.get_interface("Playroom")
# Keep a reference to the callback so it doesn't get garbage collected
var jsBridgeReferences = []
func bridgeToJS(cb):
	var jsCallback = JavaScriptBridge.create_callback(cb)
	jsBridgeReferences.push_back(jsCallback)
	return jsCallback

var player_states = []
var player_scenes = []
var game_launched = false
var speed = 100
# Called when the node enters the scene tree for the first time.
func _ready():
	var initOptions = JavaScriptBridge.create_object("Object")
	Playroom.insertCoin(initOptions, bridgeToJS(onInsertCoin))


# Called when the host has started the game
func onInsertCoin(args):
	print("Coin Inserted")
	game_launched = true
	Playroom.onPlayerJoin(bridgeToJS(onPlayerJoin))
 
# Called when a new player joins the game
func onPlayerJoin(args):
	var state = args[0]
	print("new player: ", state.id)
	var player = get_tree().get_root().get_node("world").get_node("Player").duplicate()
	player.visible = true
	add_child(player)
	
	player_states.push_back(state)
	player_scenes.push_back(player)
	
	# Listen to onQuit event
	var onQuitCb = func onPlayerQuit(args):
		print("player quit: ", state.id)
		player_states.erase(state)
		player_scenes.erase(player)
		remove_child(player)
	state.onQuit(bridgeToJS(onQuitCb))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !game_launched:
		return
	# First we send our input to Playroom state
	var direction = Input.get_vector("left","right","up","down")
	print(direction.x, direction.y)
	Playroom.myPlayer().setState("input_x", direction.x)
	Playroom.myPlayer().setState("input_y", direction.y)
	
	# Now we loop over all Players
	for i in player_scenes.size():
		var state = player_states[i]
		var scene = player_scenes[i]
		var current_input_x = 0
		var current_input_y = 0
		if state.getState("input_x"):
			current_input_x = state.getState("input_x")
		if state.getState("input_y"):
			current_input_y = state.getState("input_y")
		
		# Play animation based on direction
		if current_input_x ==0 and current_input_y ==0:
			scene.player_state = "idle"
		elif current_input_x !=0 or current_input_y !=0:
			scene.player_state = "walking"

		scene.velocity.x = current_input_x * speed
		scene.velocity.y = current_input_y * speed
		scene.move_and_slide()

		scene.play_anim(current_input_x, current_input_y)
		
		# On host, we check input and apply velocity to the player
		if (Playroom.isHost()):
			scene.velocity.x = current_input_x * speed
			scene.velocity.y = current_input_y * speed
			scene.move_and_slide()
			scene.play_anim(current_input_x, current_input_y)
			state.setState("x", scene.get_position().x)
			state.setState("y", scene.get_position().y)
		else:
			# On client, we update the player position based on the state
			scene.set_position(Vector2(state.getState("x"), state.getState("y")))
			
		
