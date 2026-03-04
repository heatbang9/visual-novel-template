extends GutTest

const TEST_DIR = "res://test/"
const TEST_SAVE_LOAD = = "res://scripts/ui/save_load_ui.gd"
const SAVE_LOAD_DIR = "res://user://saves/"
const GALLERY_MANAGER_PATH = "res://addons/gallery_system/gallery_manager.gd"

# Test GalleryManager
func test_gallery_manager():
    # Test CG unlock
    GalleryManager.register_cg_category(
        "main_story",
        [
            {
                "id": "cg_01",
                "title": "First Meeting",
                "description": "Main character's first appearance",
                "image_path": "res://assets/gallery_system/test_data/cg_01.png",
                "thumbnail_path": "res://assets/gallery_system/test_data/cg_01_thumb.png",
                "unlock_condition": {"flag": "first_meeting_complete"}
            }
        ]
    )
    
    # Test auto-save
    var save_slot = 0
    GameDataManager.save_game(0)
    
    assert_true, "Auto-save should have been after save")
    assert(GameDataManager.is_auto_save_enabled(), "Auto-save should be enabled")
    
    # Test save slot thumbnails
    var save_path = SAVE_DIR + "save_0.json"
    var file = FileAccess.open(save_path, FileAccess.WRITE)
    if file:
        file.store_line(JSON.stringify({
            "thumbnail_path": "res://assets/gallery_system/test_data/cg_01_thumb.png",
            "save_time": "2024-01-01",
            "scene": "test_scene",
        }))
    
    _update_slot_list()
    _update_thumbnail_display()
    
    # Test slot deletion
    _get_slot_info(0)
    _on_delete_pressed()
    
    # Verify deletion
    assert(_get_slot_info(0).is_empty(), "Slot 0 should not exist after deletion")


func test_gallery_ui():
    var gallery_ui = preload("res://addons/gallery_system/gallery_ui.tscn").instantiate()
    add_child(gallery_ui)
    gallery_ui.open()
    
    # Test UI functionality
    assert(gallery_ui.visible)
    assert(gallery_ui.has_method("open"))
    assert(gallery_ui.has_method("close"))
    gallery_ui.queue_free()
    
    # Test save/load UI
    var save_load_ui = preload("res://scripts/ui/save_load_ui.tscn").instantiate()
    add_child(save_load_ui)
    save_load_ui.open()
    
    # Test UI functionality
    assert(save_load_ui.visible)
    assert(save_load_ui.has_method("open"))
    assert(save_load_ui.has_method("close"))
    save_load_ui.queue_free()
