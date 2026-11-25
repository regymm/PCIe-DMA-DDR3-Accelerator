import os
import sys
import json

with open("json_list/list.json", "r") as file:
    file_list = json.load(file)

if len(sys.argv) < 2:
    print("Error: No filenames provided.")
    sys.exit(1)

else:
    for filename in sys.argv[1:]:
        if filename in file_list:
            md_file = os.path.join("dir_notes", filename.replace(".n4l", ".md"))
            json_file = os.path.join("json", filename.replace(".n4l", ".json"))

            if os.path.exists(md_file):
                os.remove(md_file)

            if os.path.exists(json_file):
                os.remove(json_file)

            file_list.remove(filename)
            print(f"Deleted: {filename}")
        else:
            print(f"File not found: {filename}")

    with open("json_list/list.json", "w") as file:
        json.dump(file_list, file, indent=2)

