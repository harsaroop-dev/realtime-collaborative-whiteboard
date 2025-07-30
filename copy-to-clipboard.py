import os
import pyperclip

INCLUDE_EXTENSIONS = {'.dart', '.yaml', '.yml'}
# Files you might want to include even if not YAML or Dart
OPTIONAL_FILES = {'.env'}


def collect_supabase_project_files(base_dir):
    file_contents = []

    # Include all .yaml and .yml files from root
    for file in os.listdir(base_dir):
        file_path = os.path.join(base_dir, file)
        ext = os.path.splitext(file)[1]
        if os.path.isfile(file_path) and (ext in INCLUDE_EXTENSIONS or file in OPTIONAL_FILES):
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    file_contents.append(f"--- FILE: {file} ---\n{content}\n")
            except Exception as e:
                file_contents.append(
                    f"--- FILE: {file} ---\n<Could not read file: {e}>\n")

    # Recursively include everything in lib/
    lib_dir = os.path.join(base_dir, 'lib')
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                full_path = os.path.join(root, file)
                try:
                    with open(full_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                        relative_path = os.path.relpath(full_path, base_dir)
                        file_contents.append(
                            f"--- FILE: {relative_path} ---\n{content}\n")
                except Exception as e:
                    file_contents.append(
                        f"--- FILE: {relative_path} ---\n<Could not read file: {e}>\n")

    return "\n".join(file_contents)


def main():
    base_dir = os.getcwd()
    data = collect_supabase_project_files(base_dir)

    try:
        pyperclip.copy(data)
        print("✅ Flutter + Supabase project files copied to clipboard.")
    except pyperclip.PyperclipException as e:
        print("❌ Failed to copy to clipboard. Error:", e)


if __name__ == "__main__":
    main()
