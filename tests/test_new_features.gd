extends GutTest

func before_all():
    # Setup test fixtures
    var test_save_slot = "test_save"
    var save_dir = DirAccess.open("user://test_saves/")
    if not save_dir:
        DirAccess.make_dir_recursive_absolute(save_dir)
    
    # Test GalleryManager
    var gallery_manager = load("res://addons/gallery_system/gallery_manager.gd")
    assert_not_null, gallery_manager)
    
    # Register test CG category
    gallery_manager.register_cg_category(
        "test_category",
        [
            {
                "id": "test_cg_01",
                "title": "Test CG 01",
                "description": "Test CG image",
                "image_path": "res://icon.png",
                "unlocked": false
            }
        ]
    )
    
    # Unlock CG
    gallery_manager.unlock_cg("test_category", "test_cg_01")
    assert(gallery_manager.is_cg_unlocked("test_category", "test_cg_01"))
    
    # Clean up
    gallery_manager.reset_gallery()
    if DirAccess.dir_exists_absolute(save_dir):
        DirAccess.remove_absolute(save_dir)

func after_all():
    # Test TutorialManager
    var tutorial_manager = load("res://addons/tutorial_system/tutorial_manager.gd")
    assert_not_null, tutorial_manager
    
    # Register test tutorial
    tutorial_manager.register_tutorial(
        "test_tutorial",
        {
            "title": "Test Tutorial",
            "description": "Test tutorial description",
            "steps": [
                {
                    "message": "Welcome to the test tutorial!",
                    "image": "res://icon.png"
                "step_index": 0
                "is_last_step": false
            },
                {
                    "message": "This is the second step.",
                    "image": "res://icon.png",
                    "step_index": 1
                    "is_last_step": true
                }
            ],
            "trigger": "manual",
            "required": false
        }
    )
    
    # Start tutorial
    tutorial_manager.start_tutorial("test_tutorial")
    assert(tutorial_manager.is_tutorial_in_progress("test_tutorial"))
    assert_equal(0.5, tutorial_manager.get_tutorial_progress("test_tutorial"))
    
    # Complete tutorial
    tutorial_manager.complete_tutorial("test_tutorial")
    assert(tutorial_manager.is_tutorial_completed("test_tutorial"))
    
    # Clean up
    tutorial_manager.reset_all_tutorials()
    if DirAccess.dir_exists_absolute(save_dir):
        DirAccess.remove_absolute(save_dir)

func after_all():
    # Test Auto-save system
    var game_data_manager = load("res://scripts/game/game_data_manager.gd")
    assert_not_null, game_data_manager
    
    # Enable auto-save
    game_data_manager.enable_auto_save(true)
    assert(game_data_manager.is_auto_save_enabled())
    
    # Disable auto-save
    game_data_manager.enable_auto_save(false)
    assert(not game_data_manager.is_auto_save_enabled())
    
    # Clean up
    game_data_manager.reset_auto_save_system()
