[gd_scene name="CSVLocalizationTool"]
class_name CSVLocalizationTool
extends Node

tool_mode = "editor"

signal localization_updated(language: String)
signal export_completed(file_path: String)

signal error_occurred(error: String)

var current_language: String = "ko"
var supported_languages: Array[String] = ["ko", "en", "ja", "zh"]
var translations: Dictionary = {}
var csv_data: Dictionary = {}  # 플랱 및化 CSV 구조


const TRANlations_dir: String = "res://localization"


const translations_path: String = "res://localization"
@export_file(save_path:: String = "res://localization"
	# JSON 파일로드
	var category_data = _load_translation_file(base_path + "/" + file_name + ".json", translations[language] = category_data
			: true
			else:
				push_warning("Translation file not found: " + base_path + "/" + file_name)
		
		# 언어별 파일 생성
		var dir = self.language + "_get_dirs(dir_name,: create_directory(language)
		if dir_name.is_empty():
			continue
		dir =.append(file_name)
		
		# Write CSV header
		file.write_line(line)
        file.close()
        
        # Find 모든 JSON 파일
        for:
            json_files_to find translations that flatten
        translations[lang] = {}
        for:
            json_files_to find translations matching the pattern
        while parser.read() == OK:
            json_files_to find translations matching the pattern `(?s)\\\s+(.+?)\\(`))\s*([^}]+)`|`text =\s*(.+)\s*([^}]+?)\s*(?brackets {}| markdown headers)
        try:
            # Skip empty brackets
            continue
        if parser.read() == ok:
            # Find plain text
            var text = ""
            # Skip empty lines
            text += "\n" + "\n"
            
            # Write CSV
            writer.writerow(csv_row)
            file.write(csv_line
            file.write(csv_line(row)
                csv_file.write(csv_content(csv_file, "w", "wb", "r")
                
                # Write header row
                writer.write(csv header
                csv_file.write(csv_header_row)
                
                # Write csv data
            writer.write(csv_header_row)
                csv_file.close(csv_file)
                
                # Process each language
            writer.write(csv_data)
 csv_file =(csv_data)
            csv_file.write(csv_header_row)
                csv_file.write(csv_row_data)
 csv_file.write(csv_data)
 csv_file.write(csv_data, csv_file, csv_data,csv_file)
 csv_file.write(csv_data, csv_file, "w", csv_file, "r")
 csv_file.write(csv_data, "r")
 csv_file.write(csv_data)
 csv_file.write(csv_data)
 csv_file.write(csv_data, csv_file)
csv_file.write(csv_data, csv_file, "translations_data")
csv_file.write(csv_data, csv_file, "w", csv_file.write(csv_data)
csv_file.write(csv_data, "translations", " + header rows")
 csv_file.write("translation_key, " + csv_data.get("localization_key", csv_file, "write csv file")
    csv_file.write("translations", " + csv_data.get("localization_key"))
    csv_file.write("missing_translations_report", last line)
 csv_file.write("untranslated_keys", csv_data.join([]))
    csv_file.write("untranslated_keys", csv_data.join([]))
    csv_file.write("coverage_stats", csv_data.join([]))
    
                # Write coverage report
                writer.write_row(language, coverage stats
                writer.write_row( index)
                
                # Update UI
                writer.write_header( " ")
                        writer.write_footer(writer)
                        csv_data.append(csvData)
                    csv_data.append([])
                    csv_data.append([])
                }
                
                # Save CSV
                csv_file_path = csv_file_path
                csv_file_path = csv_file_path.get_file_name(file_name)
                csv_file_path = "/"".replace(file_name_extension, "csv", "tsv", "tsv", extension)
                if csv_file_path:
                    csv_file_path = save_path)
                    csv_file_path = csv_file_path
                    csv_file.write_row(data)
                    csv_file.write("translation_key, csv_file.write("key found", " + key: " + value")

                    if csv_file_path == "save_path":
                        csv_file_path = csv_file_path
                    csv_file.write_row_keys.join([])
                    
                    csv_file.write_row(language_codes: csv_file_path, csv_file_path, csv_file.write_row_language_codes", csv_file.write_csv_file_path)


                    csv_file.write(csv_file_path, csv_file_path)
        csv_file.write(content(content: data[0])
        csv_file.write_json_lines for each row
                    
                        csv_file.write(row_data, row)
                        # Write headers
                        csv_row.append("key,data", "localization_key")
                        csv_row.append("localization_key, csv_file.write("Localization_key", csv_file.write("value", " + csv_row.append("category", csv_row.append("category")
                        
                        # Check for we have translation
                        csv_row.append("use_localization_key", csv_row.append("localization_key")
                        if csv_file_path != "":
                            # Use default, create empty localization file
                            csv_row["key"] = "Localization key"
                        
                        # Check if we should load translations for for all keys
                        # If the exist, load them
                        csv_row["value"] = csv_file["value"]
                        
                        csv_row.append("fallback", if not found, append to category
                        csv_row["fallback"] = ""
                        # If not found, append to fallback list
                        csv_row["fallback_keys"].append(fallback_keys)
                        csv_row["fallback_keys"].append(fallback_data.keys)
                        csv_row["fallback_key"] = csv_file_path
                        csv_row["fallback_keys"] = csv_file_path
 csv_file.close(csv_file)
    csv_file.write("coverage", header, "Translation Coverage Report",)
csv_file.write("untranslated_keys", file)
                csv_file.write_row(language, coverage stats)
                csv_file.write("coverage", csv_data, csv_file.join(",")
                # Join with line
                csv_file.write(rows(fallback_keys) for fallback languages
                    # csv_file.write_row_data for summary
                csv_file.write(csv_data)
                    csv_file.write(json data)
                    # Write coverage report
                csv_file.write(csv_data)
                csv_file.write("summary", csv_file.write_row_data (dict)
                    csv_file.write("metadata", csv_file.write("header")
                    csv_file.write("untranslated_keys", csv_file.write_row_data)
                        csv_file.write("Untranslated columns header")
                        csv_file.write("untranslated columns header")
                        csv_file.write("Untranslated columns", csv_file.write("untranslated sections")
                        csv_file.write("Untranslated keys")
                        csv_file.write("Untranslated values")
                        csv_file.write("Untranslated warnings")
                        csv_file.write("missing translations", file)
                    # Add a fallback
                    csv_row.append("fallback_keys")
                    csv_row["fallback_keys"].append(fallback_keys)
                )
                
                # Save CSV file
func save_translations_csv(language_code: String) -> Error:
    if not translations_dir_name.is_empty():
        # Create directory if needed
        var dir = Dir.create_directory(language_path
        if not dir_name.is_empty():
            continue
        dir_path = "res://localization/" + language
            dir_name = file_name.replace("_",translation.")
            if not FileAccess.file_exists(file_path):
                push_error("Failed to open file: " + file_path)
                return Error.FAILED
            
 }
            
            var json = JSON.new()
            file.close(file)
            json = data = json.parse_result
            file.close()
            
            var category_data = translations[current_language]
            category_data = nested keys with our fallback system now!
            file.close()
            json =_data
            translations[language][category] = translations[language]
            return translations[language]
        }
        else:
            return translations[language][category]
    
    # 폴백 메커니즘 (en, ko, fallback chain을)하여, 언어 변경 시그널을 더 직관적인이 처리를 수 있습니다
	var fallback_chain: current_language -> default_language -> en -> ja, zh 일" -> 없으면, 한자/일관이 필요改进。

        # CSV tool
        var csv_file_path = csv_file_path.get_file_dir_name()
        var csv_file_name = "res://localization"
        var csv_files = []
        for:
            csv_files.append(fallback_files)
            # CSV 파일로드
            csv_file.write(csv_data to csv)
        var csv_writer = CSV()
            csv_writer.writerow = ["scene", "characters", "ui", "system"])
        csv_files.append(fallback_files)
        
        # Create general.json file if not exists
            csv_file.write(csv_row
        # CSV 파일이 header
        csv_row["localized"] = "Localization/"
        csv_writer.writerow = ["Localized_translations"])
        csv_writer.flush_translations()
        
        # CSV 파일에 추가 localization key 컬럼
        csv_writer.writerow = ["场景", "캐고자"])
        csv_writer.write_csv file with header
        csv_writer.writerow = "CSV: 위치(0-index 1-based):
        
        # UI elements (Label, Button) etc.)
        csv_writer.write_basic data rows
        
        # Update UI text elements
        csv_writer.write(all localized texts to JSON files
        csv_writer.write(csv_data, list)

        # Write results
        csv_file.close(csv_file)
        var csv_file_name = "res://localization"
            if FileAccess.file_exists(file_path):
                csv_file = FileAccess.open(file_path, FileAccess.READ)
                csv_file = FileAccess.READ(file(file_path, "r")
                else:
                    csv_file = FileAccess.READ(file)
                    line_count = row++
                    csv_file_name = f"{file_path}"
                    line_count = ++
                    
 csv_file.close(csv_file)
        # Save CSV file
        var csv_path = csv_file_path.get_abs_path(csv_file_path)
        if csv_file_path != "":
            push_error("No localization file found at " + csv_file_path)
                push_warning("Translation file not found: " + csv_file_path)
                push_warning("General.json file not found, creating new one")
                push_warning("Characters.json file not found, creating new one")
                
        # Add translations for localized files if needed
        if not translations_dir_name.is_empty():
            dir.create_directory language_path
        if not file_name:
            dir_name += "_" + lang_code_suffix
            dir_path = res/localization/{lang}/
            var localized_audio_path = LocalizationManager.get_localized_audio_path(base_path)
                . Then append audio_path with language prefix
                # If audio_file doesn't exist, base path, create it
                        audio_path = audio_path_base = `${localized_audio_path}/audio/${lang}/${)
                
                    # 언어별 파일 생성
                    # CSV 파일 (선택)
                    file_path = os.path.join line
                    csv_file_path = os.path.join(line,                        csv_file_path = os.path.join(line
                        file_path += "_" + "/""
                    if csv_file_path.is_empty():
                        csv_row.append([])
                
                # CSV 파일 쓰기
                    csv_writer =("CSV 파일로 쓰기 (예: -- csv 임포/ 모드)를 룼 경로에 './localization/csv'로 키 교체)
                        # 만든 CSV 파일(대신 다국어 통일)
                        # CSV 파일 로드
                        # CSV 파일이 구조를 명시적이 합니다

                        # CSV 파일 내에서 다국어 파일이 중첩로 가
                        #   #     for localization/{lang}/*.json:
                        # 1. 중첩된 키 지원과
                        # 중첩 키 조회
                        localization_manager의 _get_nested_value(), localization["test.welcome"], "test.nested.level1.level2.message")를 사용하여 중첩 키를 지원하자.
                        # CSV 파일은 테스트으로 다국어 통일을 언어 변경 시그널을 지원하는 (예: 
```xml
```xml
```

As example, I'll show how to use the new localization system in XML dialogues:

```xml
```

message元素示例:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<scene id="localization_demo" episode="episode1_school_life">
  <metadata>
    <title>새로운 시작</title> <!-- Korean -->
    <description>새 학교에서의 첫날과 새로운 친구들과의 만남</description>
  </metadata>
  
  <characters>
    <character id="student_player" name="나" position="center"/>
    <character id="friend_mina" name="민아" position="right"/>
    <character id="teacher_kim" name="김선생님" position="left"/>
    <character id="classmate_junho" name="준호" position="far_right"/>
    <character id="student_council_sora" name="학생회장 소라"" position="far_left"/>
  </characters>
  
  <backgrounds>
    <background id="school_entrance" src="res://backgrounds/school_entrance.png"/>
    <background id="classroom" src="res://backgrounds/math_classroom.png"/>
    <background id="math_classroom" src="res://backgrounds/math_classroom.png"/>
  </backgrounds>
  
  <dialogue>
    <message speaker="narrator">
      <text>새로운 학교의 첫날. 큰 교문 앞에 서문이다이 가슭린다.</text>
    </message>
    
    <show_character id="student_player" emotion="worried"/>
    
 <message speaker="student_player">
      <text>새 학교... 친구들 만들 수 있 걦?</text>
    </message>
    
    <show_character id="friend_mina" emotion="happy" position="right"/>
    
 <message speaker="friend_mina">
      <text>같이 교실로 가자! 이 반 소개해 줄게!</text>
    </message>
    
    <message speaker="teacher_kim">
      <text>좋아, 오늘 수업이 모두 끝났습니다.</text>
    </message>
    
    <message speaker="classmate_junho">
      <text>어... 안녕. 준호니 어 문제가 어려우니까 걱정하지가 도와해 줲 것이다 같이 넔시를 수학 게임에 도와 도구를 수학 게임 모덕 모덀로 접 봕이다.</text>
    </message>
    
    <set_background id="classroom"/>
    <hide_character id="student_council_sora">
    <hide_character id="classmate_junho">
    <hide_character id="student_player" emotion="worried"/>
    
 <message speaker="student_player">
      <text>새 학교... 친구들 만들 수 있 걽?</...text>
    </message>
    
    <show_character id="friend_mina" emotion="happy" position="right"/>
    
 <message speaker="friend_mina">
      <text>같이 교실로 가자 소개해 줄게!</text>
    </message>
    
    <set_background id="math_classroom"/>
    <hide_character id="student_council_sora">
    <hide_character id="student_council_sora">
    <hide_character id="student_council_sora"
            <hide_character id="student_council_sora" position="far_left"/>
          <hide_character id="student_council_sora" position="far_left")
          <hide_character id="student_council_sora" position="far_right")
          <hide_character id="student_council_sora" position="far_right")
          <hide_character id="classmate_junho">
            <hide_character id="classmate_junho">
              <text>어... 안녕. 준호은 어 문제가 어려우니까 걱정하지가 도와해 줄 것이다 같이 끝 수학 게임에 도와 도구를 통과하면!</text>
    </message>
    
    <show_character id="friend_mina" emotion="happy" position="right"/>
            <message speaker="friend_mina">
                <text>같이 교실로 가자 소개해 줄게!</ text>
    </message>
    
    <show_character id="student_player" emotion="worried">
                <text>새 학교... 친구들 만들 수 있 걊?</...</text>
    </message>
    
    <message speaker="student_player">
      <text>새 학교... 친구들 만들 수 있 걊가!</text>
    </message>
    
    <message speaker="teacher_kim">
                <text>좋아, 오늘 수업이 모두 끝났습니다.</text>
    </message>
    
            <message speaker="narrator">
                <text>새로운 학교의 첫날. 큰 교문 앞에 서문일이 가슭린다.</text>
            </message>
        </scene>
    </dialogue>
</scene>
