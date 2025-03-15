# File: addons/ollama_assistant/ollama_dock.gd
@tool  # This annotation allows the script to run in the editor
extends Control

# Class variables
var ollama_client = null  # Will hold our OllamaClient instance
var editor_interface  # Will store a reference to Godot's editor interface
var current_script  # Will hold the currently active script in the editor
# System prompt that will be sent to Ollama to help it understand the context
var system_prompt = """You are a helpful coding assistant for Godot 4.4 Game Engine using GDScript.
Focus on providing code solutions, explanations, and suggestions.
When providing code, ensure it's compatible with Godot 4.4.
"""

# UI element references - these will be created in _ready()
var script_content_label: Label  # Shows preview of current script
var prompt_input: TextEdit  # Where user types their question
var submit_button: Button  # Button to send prompt to Ollama
var response_output: RichTextLabel  # Shows Ollama's response
var model_select: OptionButton  # Dropdown to select Ollama model
var loading_indicator: ProgressBar  # Shows when waiting for response

# Constructor - runs when class is instantiated
func _init():
	# Set a name for this control node
	name = "OllamaAssistant"
	
	# Create the Ollama client - using the class_name directly
	# since it's defined in ollama_client.gd
	ollama_client = OllamaClient.new()
	add_child(ollama_client)
	
	# Connect to client signals using Godot 4.4 syntax
	ollama_client.response_received.connect(_on_ollama_response)
	ollama_client.error_occurred.connect(_on_ollama_error)

# Called when the node enters the scene tree
func _ready():
	# Main vertical container that will hold all UI elements
	var main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(main_vbox)
	
	# --- CURRENT SCRIPT SECTION ---
	var script_section = VBoxContainer.new()
	main_vbox.add_child(script_section)
	
	var script_header = Label.new()
	script_header.text = "Current Script:"
	script_section.add_child(script_header)
	
	# Label that will show the current script path and preview
	script_content_label = Label.new()
	script_content_label.text = "No script selected"
	script_content_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	script_section.add_child(script_content_label)
	
	# --- MODEL SELECTION SECTION ---
	var model_section = HBoxContainer.new()
	main_vbox.add_child(model_section)
	
	var model_label = Label.new()
	model_label.text = "Ollama Model:"
	model_section.add_child(model_label)
	
	# Dropdown for selecting different Ollama models
	model_select = OptionButton.new()
	model_select.add_item("codellama")  # Default option
	model_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	model_section.add_child(model_select)
	
	# Button to refresh the list of available models
	var refresh_button = Button.new()
	refresh_button.text = "Refresh Models"
	refresh_button.pressed.connect(_on_refresh_models_pressed)
	model_section.add_child(refresh_button)
	
	# --- PROMPT INPUT SECTION ---
	var prompt_section = VBoxContainer.new()
	main_vbox.add_child(prompt_section)
	
	var prompt_label = Label.new()
	prompt_label.text = "Ask Ollama:"
	prompt_section.add_child(prompt_label)
	
	# Text area for entering prompts
	prompt_input = TextEdit.new()
	prompt_input.placeholder_text = "Enter your coding question here..."
	prompt_input.size_flags_vertical = Control.SIZE_EXPAND_FILL
	prompt_input.custom_minimum_size = Vector2(0, 100)
	prompt_section.add_child(prompt_input)
	
	# --- SUGGESTION BUTTONS ---
	# These provide quick templates for common requests
	var suggestion_section = HBoxContainer.new()
	prompt_section.add_child(suggestion_section)
	
	var suggest_refactor = Button.new()
	suggest_refactor.text = "Refactor"
	suggest_refactor.pressed.connect(_on_suggest_refactor_pressed)
	suggestion_section.add_child(suggest_refactor)
	
	var suggest_optimize = Button.new()
	suggest_optimize.text = "Optimize"
	suggest_optimize.pressed.connect(_on_suggest_optimize_pressed)
	suggestion_section.add_child(suggest_optimize)
	
	var suggest_explain = Button.new()
	suggest_explain.text = "Explain"
	suggest_explain.pressed.connect(_on_suggest_explain_pressed)
	suggestion_section.add_child(suggest_explain)
	
	var suggest_complete = Button.new()
	suggest_complete.text = "Complete Function"
	suggest_complete.pressed.connect(_on_suggest_complete_pressed)
	suggestion_section.add_child(suggest_complete)
	
	# --- SUBMIT BUTTON AND LOADING INDICATOR ---
	var submit_section = HBoxContainer.new()
	prompt_section.add_child(submit_section)
	
	submit_button = Button.new()
	submit_button.text = "Submit to Ollama"
	submit_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	submit_button.pressed.connect(_on_submit_pressed)
	submit_section.add_child(submit_button)
	
	# Progress bar used as a loading indicator
	loading_indicator = ProgressBar.new()
	loading_indicator.value = 50
	loading_indicator.custom_minimum_size = Vector2(100, 10)
	loading_indicator.visible = false  # Hidden by default
	submit_section.add_child(loading_indicator)
	
	# --- RESPONSE SECTION ---
	var response_section = VBoxContainer.new()
	response_section.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(response_section)
	
	var response_label = Label.new()
	response_label.text = "Response:"
	response_section.add_child(response_label)
	
	# Text area that shows Ollama's response
	response_output = RichTextLabel.new()
	response_output.bbcode_enabled = true  # Allows formatting in the response
	response_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
	response_output.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	response_output.selection_enabled = true  # Allows user to select and copy text
	response_output.custom_minimum_size = Vector2(0, 200)  # Fixed height of 200 pixels
	response_output.scroll_active = true  # Enable scrolling within the text box
	response_output.scroll_following = true  # Auto-scroll to show new content
	response_section.add_child(response_output)
	
	# Button to apply code from response to the script
	var apply_button = Button.new()
	apply_button.text = "Apply to Script"
	apply_button.pressed.connect(_on_apply_pressed)
	response_section.add_child(apply_button)
	
	# Fetch the list of available models from Ollama
	# Make sure the client exists before calling methods on it
	if ollama_client != null:
		ollama_client.get_available_models()
	else:
		response_output.text = "Error: Ollama client not initialized properly."

# Sets up the dock with a reference to the editor interface
func setup(editor_interface_ref):
	editor_interface = editor_interface_ref

# Updates the UI when a different script is selected
func set_current_script(script):
	current_script = script
	if current_script:
		var script_path = current_script.resource_path
		var script_text = current_script.source_code
		
		# Update the UI with script info
		script_content_label.text = "Path: " + script_path + "\n"
		
		# Limit the displayed script text to avoid UI lag
		var preview_length = 200
		if script_text.length() > preview_length:
			script_content_label.text += script_text.substr(0, preview_length) + "..."
		else:
			script_content_label.text += script_text
	else:
		script_content_label.text = "No script selected"

# --- BUTTON HANDLERS ---

# Refreshes the list of available Ollama models
func _on_refresh_models_pressed():
	if ollama_client != null:
		ollama_client.get_available_models()
		response_output.text = "Refreshing available models..."
	else:
		response_output.text = "Error: Ollama client not initialized properly."

# Handles the submit button press
func _on_submit_pressed():
	if current_script and !prompt_input.text.is_empty():
		_send_to_ollama(prompt_input.text)
	else:
		response_output.text = "Please select a script and enter a prompt."

# Sets up a refactor request template
func _on_suggest_refactor_pressed():
	if current_script:
		var prompt = "Refactor the following GDScript code to improve readability and maintainability:"
		prompt_input.text = prompt
	else:
		response_output.text = "Please select a script first."

# Sets up an optimization request template
func _on_suggest_optimize_pressed():
	if current_script:
		var prompt = "Optimize the following GDScript code for better performance:"
		prompt_input.text = prompt
	else:
		response_output.text = "Please select a script first."

# Sets up a code explanation request template
func _on_suggest_explain_pressed():
	if current_script:
		var prompt = "Explain what the following GDScript code does in detail:"
		prompt_input.text = prompt
	else:
		response_output.text = "Please select a script first."

# Sets up a function completion request template
func _on_suggest_complete_pressed():
	if current_script:
		var prompt = "Complete the following GDScript function with appropriate implementation:"
		prompt_input.text = prompt
	else:
		response_output.text = "Please select a script first."

# Sends the current script and prompt to Ollama
func _send_to_ollama(prompt: String):
	if current_script and ollama_client != null:
		# Show loading state in the UI
		loading_indicator.visible = true
		submit_button.disabled = true
		response_output.text = "Waiting for Ollama response..."
		
		# Get the selected model from the dropdown
		var selected_model = model_select.get_item_text(model_select.selected)
		
		# Enhance the system prompt to encourage proper code formatting
		var enhanced_system_prompt = system_prompt + "\nWhen providing code, please wrap it in ```gdscript code blocks, and make sure the code is complete and ready to use."
		
		# Create the full prompt that combines:
		# 1. The system prompt (instructions for Ollama)
		# 2. The current script content
		# 3. The user's specific request
		var full_prompt = enhanced_system_prompt + "\n\nScript:\n```gdscript\n" + current_script.source_code + "\n```\n\nRequest: " + prompt
		
		# Log what we're sending for debugging
		print("Sending request to Ollama with model: ", selected_model)
		
		# Send the request to Ollama
		ollama_client.generate_response(full_prompt, selected_model)
	else:
		if ollama_client == null:
			response_output.text = "Error: Ollama client not initialized properly."
		else:
			response_output.text = "No script selected."

# --- OLLAMA RESPONSE HANDLERS ---

# Handles responses from the Ollama client
func _on_ollama_response(text: String):
	# Check if this is a list of models or a text response
	if text.begins_with("["):
		# This is a models list response (JSON array)
		var models = JSON.parse_string(text)
		model_select.clear()
		for model in models:
			model_select.add_item(model)
		response_output.text = "Available models updated."
	else:
		# This is a text generation response
		response_output.text = text
		
		# Log to console for debugging
		print("Received response from Ollama:")
		print(text.substr(0, min(200, text.length())) + "...")
	
	# Reset UI state
	loading_indicator.visible = false
	submit_button.disabled = false
	
	# Ensure the response box is large enough to show content
	if response_output.get_content_height() > response_output.size.y:
		pass

# Handles errors from the Ollama client
func _on_ollama_error(error_message: String):
	response_output.text = "Error: " + error_message
	loading_indicator.visible = false
	submit_button.disabled = false

# --- CODE APPLICATION ---

# Applies code from the response to the current script
func _on_apply_pressed():
	if current_script and !response_output.text.is_empty():
		# Log the current script we're working with
		print("Attempting to apply code to script: ", current_script.resource_path)
		
		# Look for code blocks in the response (```gdscript ... ```)
		var response_text = response_output.text
		var code_start = response_text.find("```gdscript")
		if code_start == -1:
			code_start = response_text.find("```")
		
		if code_start != -1:
			# Found a code block - extract the code between the markers
			var code_content_start = response_text.find("\n", code_start) + 1
			var code_end = response_text.find("```", code_content_start)
			
			if code_end != -1:
				var code_to_apply = response_text.substr(code_content_start, code_end - code_content_start)
				print("Extracted code to apply: ", code_to_apply.substr(0, min(50, code_to_apply.length())) + "...")
				
				# Get the original script content
				var original_code = current_script.source_code
				
				# Create a new script with the modified content
				var modified_code = original_code + "\n\n# Code added by Ollama Assistant:\n" + code_to_apply
				
				# Update the script with modified code
				print("Original code length: ", original_code.length())
				print("Modified code length: ", modified_code.length())
				
				# Store the old code to verify changes
				var before_change = current_script.source_code
				
				# Update the script resource
				current_script.source_code = modified_code
				
				# Verify the change was applied to the resource
				var after_change = current_script.source_code
				print("Did source_code property change? ", before_change.length() != after_change.length())
				
				# Save the resource to make changes permanent
				var save_error = ResourceSaver.save(current_script, current_script.resource_path)
				if save_error != OK:
					print("ERROR saving script: ", save_error)
					response_output.text += "\n\nError saving script: " + str(save_error)
					return
				else:
					print("ResourceSaver.save() returned OK")
				
				# Force reload the script
				var new_script = load(current_script.resource_path)
				if new_script:
					print("Successfully reloaded script from disk")
					# Check if changes were saved to disk
					if new_script.source_code.length() != original_code.length():
						print("Verified script was changed on disk")
					else:
						print("WARNING: Script on disk doesn't seem to have changed!")
				
				# Notify the filesystem about the change
				editor_interface.get_resource_filesystem().scan()
				
				# Attempt to reload the script in the editor
				if editor_interface.has_method("reload_edited_resources"):
					editor_interface.reload_edited_resources()
					print("Called reload_edited_resources()")
				
				# Need to force the editor to reload the current tab
				var script_editor = editor_interface.get_script_editor()
				if script_editor:
					# Try to force a reload of the script editor
					# This will depend on the specific Godot version's API
					if script_editor.has_method("reload_scripts"):
						script_editor.reload_scripts()
						print("Called script_editor.reload_scripts()")
					
				# Update UI with success message
				response_output.text += "\n\nCode applied to script and saved. If you don't see changes, try closing and reopening the script tab."
				print("Successfully applied code changes to: ", current_script.resource_path)
			else:
				response_output.text += "\n\nCouldn't find a complete code block to apply."
		else:
			response_output.text += "\n\nNo code block found in the response. Make sure the response contains code wrapped in ```gdscript ``` markers."
	else:
		response_output.text = "No script selected or no response to apply."
