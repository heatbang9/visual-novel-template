# Visual Novel Template Collection

A comprehensive multi-game visual novel template system built with Godot 4.5, featuring XML-based scenario scripting, multi-language support, and professional-grade visual effects.

## 🎮 Featured Games

### 1. 학교 생활 로맨스 (School Life Romance)
- **Playtime**: ~65 minutes
- **Genre**: Romance, School, Comedy, Drama
- **Routes**: 4 main paths (Confident/Gentle/Observant/Yuki-focused)
- **Endings**: 4 different conclusions
- **Features**: Character affection system, school festival events, multiple dialogue branches

### 2. 미스터리 탐정 (Mystery Detective) 
- **Playtime**: ~75 minutes
- **Genre**: Mystery, Detective, Thriller, Noir
- **Features**: Evidence collection, interrogation system, multiple suspects
- **Investigation Styles**: 3 different approaches
- **Endings**: 5 possible outcomes

### 3. 스페이스 어드벤처 (Space Adventure)
- **Playtime**: ~90 minutes  
- **Genre**: Sci-Fi, Adventure, Space Drama
- **Routes**: Science/Diplomacy/Exploration paths
- **Features**: Crew management, galactic politics, alien encounters
- **Endings**: 4 major conclusions

## 🛠️ Core Systems

### Game Management
- **GameProjectManager**: Multi-game project handling
- **Game Selector Menu**: Main menu with game selection
- **Build Configurator**: Development/Production/Single-game builds

### Visual & Audio
- **VisualDirector**: Advanced visual effects and animations
- **AudioManager**: BGM, SFX, and TTS voice synthesis
- **EnhancedSceneLoader**: Professional scene direction

### Localization & Scenarios
- **LocalizationManager**: Full multi-language support (Korean/English/Japanese)
- **ScenarioManager**: XML-based scenario scripting
- **ChoiceUI**: Interactive choice system with animations

## 🚀 Quick Start

### Prerequisites
- Godot 4.5 or later
- 4GB RAM minimum (8GB recommended)
- 2GB storage space

### Installation
1. Clone this repository
2. Open `project.godot` in Godot
3. Run the project
4. Select a game from the main menu

### Creating New Games
1. Create new folder in `games/`
2. Add game entry to `games/games_config.json`
3. Create XML scenarios following the guide
4. Add localization files

## 📖 Documentation

### Developer Guides
- **[XML Scenario Guide](docs/XML_SCENARIO_GUIDE.md)**: Basic XML scenario creation
- **[Enhanced XML Guide](docs/ENHANCED_XML_GUIDE.md)**: Advanced features and effects  
- **[LLM Integration Guide](docs/LLM_SCENARIO_CREATION.md)**: AI-assisted scenario generation

### System Architecture
```
addons/
├── game_manager/          # Multi-game project management
├── visual_effects/        # Visual effects and animations  
├── audio_system/          # Audio and TTS management
├── localization_system/   # Multi-language support
├── scenario_system/       # XML scenario processing
└── choice_system/         # Interactive choice UI

games/
├── school_romance/        # High school romance game
├── mystery_detective/     # Detective thriller game  
└── space_adventure/       # Sci-fi space exploration
```

## 🎨 XML Scenario Features

### Basic Elements
```xml
<scenario name="game_story" default_route="main">
    <route id="main" name="Main Story">
        <scene id="opening" path="scenes/opening.xml">
            <choice id="choice1" text="Be confident">
                <effect variable="confidence" modifier="add" value="2"/>
            </choice>
        </scene>
    </route>
</scenario>
```

### Advanced Features
- **Character Animations**: Entry/exit effects, emotion changes
- **Visual Effects**: Screen transitions, camera movements, lighting
- **Audio Integration**: BGM, SFX, voice acting, TTS generation
- **Multi-language**: Automatic text and audio localization
- **Conditional Logic**: Variables, requirements, branching paths

### Example Advanced Scene
```xml
<scene name="dramatic_moment">
    <action type="play_bgm" audio_path="dramatic_theme.ogg" fade_in="true"/>
    <action type="camera_zoom" zoom_level="1.5" duration="2.0"/>
    <action type="character_enter" target="heroine" animation="slide_right"/>
    
    <message speaker="heroine" emotion="surprised" auto_voice="true">
        I can't believe this is happening!
        <translation lang="ko">이런 일이 일어날 줄 몰랐어요!</translation>
        <translation lang="ja">こんなことが起こるなんて信じられない！</translation>
    </message>
    
    <choice id="comfort_her" text="Comfort her gently">
        <requirement variable="affection" operator=">=" value="5"/>
        <effect variable="affection" modifier="add" value="3"/>
    </choice>
</scene>
```

## 🌐 Multi-Language Support

### Supported Languages
- **한국어 (Korean)**: Native language
- **English**: Full translation
- **日本語 (Japanese)**: Complete localization

### Features
- Automatic font switching per language
- TTS voice generation per language
- Localized audio file loading
- Real-time language switching

## 🔧 Build & Deployment

### Build Types
```bash
# Development build (all games, debug mode)
godot --headless --export-debug "Windows Desktop" "builds/dev/"

# Production build (selected games only)
godot --headless --export-release "Windows Desktop" "builds/prod/"

# Single game build
godot --headless --export-release "Windows Desktop" "builds/single/"
```

### Build Configuration
Use `tools/build_configurator.gd` to set up different build profiles:
- **Development**: All games, admin panel, debug features
- **Production**: Optimized, selected games only
- **Single Game**: One game per build for focused distribution

## 📊 Statistics

- **Total Playtime**: ~230 minutes (4+ hours of content)
- **Choice Points**: 70+ interactive decisions
- **Endings**: 13 different conclusions across all games
- **Languages**: 3 fully supported languages
- **Code Lines**: 7,000+ lines of GDScript
- **XML Scenarios**: 20+ detailed scenes

## 🎯 Target Audience

- **Content Rating**: Teen+
- **Platforms**: Windows, macOS, Linux
- **Target Demographics**: Visual novel fans, indie game enthusiasts
- **Accessibility**: Full keyboard navigation, TTS support

## 🤝 Contributing

### Adding New Games
1. Study existing game structure
2. Create game folder with required subdirectories
3. Write XML scenarios following guidelines
4. Add game configuration to `games_config.json`
5. Test thoroughly across all supported languages

### Code Contributions
- Follow GDScript style guidelines
- Add documentation for new features
- Test with multiple games and languages
- Ensure compatibility with existing save systems

## 📄 License

This project is released under the MIT License. See [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Godot Engine**: Open-source game engine
- **Dialogic Plugin**: Visual novel framework foundation
- **Community Contributors**: Feedback and testing
- **Claude AI**: Development assistance and code generation

## 📞 Support

- **Email**: support@visualnovelstudio.com
- **Discord**: https://discord.gg/visualnovels
- **Issues**: GitHub Issues tab
- **Documentation**: See `/docs` folder

---

**🤖 This project was developed with assistance from Claude AI**

*Built with ❤️ for the visual novel community*