# File: addons/ollama_assistant/ollama_client.gd
@tool  # This annotation allows the script to run in the editor, not just during gameplay
extends Node

# Define a custom class for use elsewhere in the project
class_name OllamaClient

# Signal declarations - these allow other nodes to "listen" for events from this client
signal response_received(text)  # Emitted when we get a successful response from Ollama
signal error_occurred(error_message)  # Emitted when an error happens

# Class variables
var http_request: HTTPRequest  # Will be used to make HTTP requests to the Ollama API
var base_url = "http://localhost:11434/api"  # Default URL for local Ollama server
var default_model = "codellama"  # Default language model to use with Ollama

# Constructor - runs when class is instantiated
func _init():
	# Create an HTTP request node and add it as a child of this node
	http_request = HTTPRequest.new()
	add_child(http_request)
	# Connect the request_completed signal to our handler function
	# This uses Godot 4.4's signal connection syntax
	http_request.request_completed.connect(_on_request_completed)

# Public method to change the default model
func set_model(model_name: String):
	default_model = model_name

# Main method to generate a response from Ollama
func generate_response(prompt: String, model: String = ""):
	# If no specific model is provided, use the default one
	if model.is_empty():
		model = default_model
	
	# Prepare the request data as a dictionary (will be converted to JSON)
	var request_data = {
		"model": model,  # Which Ollama model to use
		"prompt": prompt,  # The text prompt to send to Ollama
		"stream": false  # Don't stream the response, get it all at once
	}
	
	# Convert the dictionary to a JSON string
	var json_string = JSON.stringify(request_data)
	# Set the content type header for JSON
	var headers = ["Content-Type: application/json"]
	
	# Send the POST request to Ollama's generate endpoint
	var error = http_request.request(base_url + "/generate", headers, HTTPClient.METHOD_POST, json_string)
	
	# Check if the request was successfully sent (not if it was successfully processed)
	if error != OK:
		error_occurred.emit("An error occurred in the HTTP request: " + str(error))

# Method to fetch all available models from Ollama
func get_available_models():
	# Make a GET request to the tags endpoint (which lists available models)
	var error = http_request.request(base_url + "/tags", [], HTTPClient.METHOD_GET)
	if error != OK:
		error_occurred.emit("Failed to fetch available models: " + str(error))

# Signal handler for when HTTP requests complete
func _on_request_completed(result, response_code, headers, body):
	# Check if the HTTP request itself was successful
	if result != HTTPRequest.RESULT_SUCCESS:
		error_occurred.emit("Failed to get a response: " + str(result))
		return
	
	# Check if we got a good HTTP status code (200 = OK)
	if response_code != 200:
		error_occurred.emit("Received HTTP response code: " + str(response_code))
		return
	
	# Try to parse the response body as JSON
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		error_occurred.emit("Failed to parse response as JSON")
		return
	
	# Handle different response structures based on which endpoint we called
	if json.has("response"):
		# This is from the /generate endpoint - emit the text response
		response_received.emit(json.response)
	elif json.has("models"):
		# This is from the /tags endpoint - extract and emit model names
		var model_names = []
		for model in json.models:
			model_names.append(model.name)
		response_received.emit(JSON.stringify(model_names))
	else:
		error_occurred.emit("Response doesn't contain expected data")
