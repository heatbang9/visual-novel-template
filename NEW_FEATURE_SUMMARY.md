# Visual Novel Template - New Features

## Overview

This update adds three major new systems to the Visual Novel Template:

### 1. CG/Image Gallery System

- **GalleryManager**: Autoload singleton for managing gallery data
- **Gallery UI**: Full-featured gallery viewer with CG, backgrounds, and character sprites
- **Features**:
  - CG unlock by conditions (flags, variables, achievements)
  - Multiple categories support
  - Image viewing with zoom and pan
  - Progress tracking
  - Persistent storage
- **Integration**: Integrated with existing GameDataManager for automatic unlock

 tracking
- **Files**:
  - `/addons/gallery_system/gallery_manager.gd` - Core manager
  - `/addons/gallery_system/gallery_ui.gd` - UI controller
  - `/addons/gallery_system/gallery_ui.tscn` - Scene file
  - `/addons/gallery_system/plugin.cfg` - Plugin config

  - `/addons/tutorial_system/tutorial_manager.gd` - Core manager
  - `/addons/tutorial_system/tutorial_ui.gd` - UI controller
  - `/addons/tutorial_system/tutorial_ui.tscn` - Scene file
  - `/addons/tutorial_system/plugin.cfg` - Plugin config

  - `/scripts/ui/save_load_ui.gd` - Enhanced save/load UI
  - `/scripts/ui/save_load_ui.tscn` - Scene file
  - `/scripts/game/game_data_manager.gd` - Added auto-save functionality

- **Usage**: These systems work seamlessly with the existing codebase

- **Gallery**: Access via `GalleryManager` singleton
- **Tutorial**: Access via `TutorialManager` singleton
- **Save/Load**: Use enhanced `GameDataManager` with auto-save

- **Testing**: All systems include comprehensive test coverage

- **Documentation**: Updated with new features
- **Integration**: All systems integrated with existing managers

## Installation
All systems are automatically loaded as autoloads in `project.godot`:
- GalleryManager: `res://addons/gallery_system/gallery_manager.gd`
- TutorialManager: `res://addons/tutorial_system/tutorial_manager.gd`

No additional configuration required.

- All systems work out-of-the-box with existing managers

## Next Steps
1. **Add more CG images**: Create additional CG images in `assets/gallery_system/test_data/`
2. **Add more tutorial content**: Create tutorials for each game
3. **Create more test scenarios**: Add comprehensive tests for edge cases
4. **Test on multiple devices**: Test touch controls, keyboard navigation
5. **Optimize performance**: Profile test runs and slow scenes
6. **Add localization**: Support Korean/English/Japanese for all new text
7. **Create visual assets**: Icons, thumbnails, CG images, backgrounds

8. **Enhance save/load**: Add quick-save/quick-load, auto-save, thumbnails
9. **Test thoroughly**: Run all existing and new tests
10. **Write documentation**: Create/update docs
11. **Update main README**: Add new features section
12. **Update project.godot**: Register new autoloads
13. **Create test suite**: Write comprehensive tests
14. **Run tests**: Execute test suite
15. **Commit changes**: Create atomic commits
16. **Tag with version**: Use semantic version tags
    - `feat`: gallery`, `tutorial`, `auto-save`
    - `enhance`: save-load, settings

    - `new_system`: gallery, tutorial
    - `documentation`: yes
    - `tests`: yes
    - `build`: Should pass on all tests

