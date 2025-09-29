@tool
extends Node

# This script provides compatibility layer for Godot 4.5 changes
# It patches major breaking changes in the API

class_name DialogicCompatibility

static func load_image_file(path: String) -> Image:
    if FileAccess.file_exists(path):
        return Image.load_from_file(path)
    return null

static func create_texture_from_image(image: Image) -> ImageTexture:
    if image:
        return ImageTexture.create_from_image(image)
    return null

static func open_file(path: String, flags: FileAccess.ModeFlags) -> FileAccess:
    return FileAccess.open(path, flags)

static func file_exists(path: String) -> bool:
    return FileAccess.file_exists(path)

static func save_png_file(image: Image, path: String) -> Error:
    return image.save_png(path)

static func make_dir(path: String) -> Error:
    var dir := DirAccess.open(".")
    if dir:
        return dir.make_dir(path)
    return Error.FAILED

static func create_image(width: int, height: int, has_mipmaps: bool = false, format: Image.Format = Image.FORMAT_RGB8) -> Image:
    return Image.create(width, height, has_mipmaps, format)