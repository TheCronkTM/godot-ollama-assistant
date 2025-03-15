# Ollama Assistant for Godot - Detailed Installation Guide

This document provides detailed installation instructions for the Ollama Assistant plugin for Godot.

## Prerequisites

Before installing the plugin, you need to have:

1. **Godot Engine 4.4** or later installed
2. **Ollama** installed on your system
3. At least one language model downloaded with Ollama

## Installing Ollama

### Windows

1. Download the Ollama installer from [https://ollama.ai/download/windows](https://ollama.ai/download/windows)
2. Run the installer and follow the prompts
3. After installation, Ollama will start automatically (look for the icon in your system tray)

### macOS

1. Download Ollama from [https://ollama.ai/download/mac](https://ollama.ai/download/mac)
2. Open the downloaded file and drag Ollama to your Applications folder
3. Open Ollama from your Applications folder

### Linux

1. Install Ollama using the following command:
   ```bash
   curl -fsSL https://ollama.ai/install.sh | sh
   ```
2. Start the Ollama service:
   ```bash
   ollama serve
   ```

## Installing a Language Model in Ollama

After installing Ollama, you need to download at least one language model. The plugin works best with code-focused models like CodeLlama.

```bash
# Pull the CodeLlama model (recommended for coding assistance)
ollama pull codellama

# Alternatively, you can try other models:
ollama pull llama3
ollama pull mistral
# etc.
```

You can see all available models at [https://ollama.ai/library](https://ollama.ai/library)

## Plugin Installation

### Method 1: Via Godot Asset Library (Recommended)

1. Open your Godot project
2. Go to the AssetLib tab in the top center of the Godot editor
3. Search for "Ollama Assistant"
4. Click on the plugin when it appears in search results
5. Click "Download" in the preview window that opens
6. When the download completes, click "Install"
7. In the installation window, make sure all files are selected and click "Install"
8. Go to Project → Project Settings → Plugins
9. Find "Ollama Assistant" in the list and check the "Enable" box

### Method 2: Manual Installation

1. Download this repository as a ZIP file or clone it with Git:
   ```bash
   git clone https://github.com/TheCronkTM/godot-ollama-assistant.git
   ```

2. Create an `addons` folder in your Godot project if it doesn't exist already

3. Copy the `ollama_assistant` folder from the downloaded repository into your project's `addons` folder. The final structure should look like:
   ```
   your_godot_project/
   ├── addons/
   │   ├── ollama_assistant/
   │   │   ├── plugin.cfg
   │   │   ├── plugin.gd
   │   │   ├── ollama_client.gd
   │   │   └── ollama_dock.gd
   ```

4. Open your Godot project
5. Go to Project → Project Settings → Plugins
6. Find "Ollama Assistant" in the list and check the "Enable" box

## Verifying Installation

After enabling the plugin, you should see a new dock on the right side of the Godot editor with the title "Ollama Assistant". If you don't see it:

1. Go to View → Docks → Make sure "Ollama Assistant" is checked
2. If you still don't see it, try restarting Godot

## Testing the Plugin

1. Make sure Ollama is running on your system
2. Open a script in the Godot editor
3. In the Ollama Assistant dock, click "Refresh Models" to verify the connection to Ollama
4. Select a model from the dropdown
5. Type a simple test query like "Explain what this script does" in the input field
6. Click "Submit to Ollama"

If you receive a response, the plugin is working correctly. If you encounter any errors, check the troubleshooting section in the README.md file.

## Updating the Plugin

### Asset Library Method
1. Go to AssetLib tab in Godot
2. Search for "Ollama Assistant"
3. If an update is available, click on it and follow the installation steps
4. Make sure to overwrite existing files when prompted

### Manual Method
1. Delete the existing `addons/ollama_assistant` folder from your project
2. Download the latest version and copy it to your project's `addons` folder
3. Restart Godot and re-enable the plugin

## Uninstalling the Plugin

1. Go to Project → Project Settings → Plugins
2. Uncheck the "Enable" box next to "Ollama Assistant"
3. To completely remove the plugin, delete the `addons/ollama_assistant` folder from your project
