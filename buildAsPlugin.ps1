# Rojo Build Script - metatablecat
# Licensed under Apache 2.0

$name = "CommandBarBridgeInjector" # Model Name
$extension = "rbxmx" # Model Extension, can be rbxm or rbxmx, do not include the .
$path = "$env:localappdata/Roblox/Plugins" # Path of where to build the model to

$path_final = "$path/$name.$extension"
rojo build --output $path_final