# Ollama Assistant for Godot

A Godot 4.4+ plugin that integrates Ollama's AI code assistant directly into the Godot editor, helping you write, refactor, optimize, and understand GDScript code without leaving your development environment.

![Ollama Assistant Screenshot](screenshots/ollama_assistant_screenshot.png)

## Features

- **Integrated Code Assistant**: Get AI-powered coding help directly in your Godot editor
- **Multiple AI Models**: Select from any model available in your local Ollama installation
- **Common Requests**: Quick buttons for code refactoring, optimization, explanation, and function completion
- **Apply Code Directly**: Apply generated code to your scripts with a single click
- **Works Offline**: Uses your local Ollama installation, so no internet connection required after setup

## Requirements

- Godot 4.4 or later
- [Ollama](https://ollama.ai/) installed locally on your machine 
- A code-focused language model (CodeLlama works well, but any model available in Ollama will work)

## Installation

### Step 1: Install Ollama

1. Download and install [Ollama](https://ollama.ai/) for your operating system
2. Pull a code-focused model:
   ```bash
   ollama pull codellama
   ```
   (You can substitute any other model you prefer)

### Step 2: Install the Plugin

#### Method A: From Asset Library (Recommended)
1. Open your Godot project
2. Go to the AssetLib tab in Godot
3. Search for "Ollama Assistant"
4. Download and install the plugin
5. Enable it in Project → Project Settings → Plugins

#### Method B: Manual Installation
1. Download this repository as a ZIP file or clone it
2. Copy the `addons/ollama_assistant` directory into your Godot project's `addons` folder
3. Enable the plugin in Project → Project Settings → Plugins

## Usage

1. After enabling the plugin, you'll see the Ollama Assistant dock on the right side of the editor
2. Select a script in the editor that you want help with
3. Choose your preferred Ollama model from the dropdown (click "Refresh Models" if none appear)
4. Type your question or request in the text box, or use one of the suggestion buttons:
   - **Refactor**: Improve code readability and maintainability
   - **Optimize**: Enhance code performance
   - **Explain**: Get a detailed explanation of your code
   - **Complete Function**: Fill in the implementation of a function
5. Click "Submit to Ollama" and wait for the response
6. To apply code from the response to your script, click "Apply to Script"

## Troubleshooting

### Common Issues

- **No models appear in dropdown**: Ensure Ollama is running and click "Refresh Models"
- **Error connecting to Ollama**: Verify Ollama is running on `localhost:11434` (default)
- **Slow response times**: Complex requests or larger scripts may take longer to process
- **Code not applying correctly**: Try closing and reopening the script after applying changes

### Logs

Check the Godot console for logs if you encounter issues. The plugin prints diagnostic information that can help identify problems.

## Customization

### Changing the Default Model

The default model is set to `codellama`. To change it, modify line 13 in `ollama_client.gd`:

```gdscript
var default_model = "your_preferred_model"
```

### Modifying the System Prompt

You can customize how the AI responds by editing the system prompt in lines 11-14 of `ollama_dock.gd`:

```gdscript
var system_prompt = """Your custom instructions here.
More instructions on a new line.
"""
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built for the Godot Engine community
- Powered by [Ollama](https://ollama.ai/)
- Inspired by various coding assistants and the potential of local AI for game development

---

Made with ❤️ for Godot developers. Happy coding!
