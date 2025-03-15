# File: addons/ollama_assistant/plugin.gd
@tool  # This annotation allows the script to run in the editor
extends EditorPlugin  # Extends EditorPlugin to create a Godot editor plugin

# Class variables
var dock  # Will hold the dock UI instance
var current_script = null  # Will track the currently active script
var script_editor = null  # Will reference the script editor

# Called when the plugin is enabled (activated in the project settings)
func _enter_tree():
	# Create an instance of our dock UI (from ollama_dock.gd)
	# Note: We're using code to create the UI instead of a TSCN scene file
	dock = load("res://addons/ollama_assistant/ollama_dock.gd").new()
	
	# Add the dock to the editor UI in the upper-right dock slot
	# DOCK_SLOT_RIGHT_UL = Upper-Left portion of the right dock area
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)
	
	# Get a reference to the script editor component of Godot
	script_editor = get_editor_interface().get_script_editor()
	
	# Connect to the editor_script_changed signal to know when the user switches scripts
	# Uses Godot 4.4's signal connection syntax
	script_editor.editor_script_changed.connect(_on_script_changed)
	
	# Pass the editor interface to our dock so it can access editor functionality
	dock.setup(get_editor_interface())

# Called when the plugin is disabled in the project settings
func _exit_tree():
	# Clean up the dock when the plugin is disabled
	if dock:
		# Remove it from the editor UI
		remove_control_from_docks(dock)
		# Queue it for deletion
		dock.queue_free()
	
	# Disconnect any connected signals to prevent errors
	if script_editor and script_editor.editor_script_changed.is_connected(_on_script_changed):
		script_editor.editor_script_changed.disconnect(_on_script_changed)

# Signal handler for when the active script in the editor changes
func _on_script_changed(script):
	# Update our reference to the current script
	current_script = script
	# If both our dock and a script exist, update the dock with the new script
	if dock and current_script:
		dock.set_current_script(current_script)
