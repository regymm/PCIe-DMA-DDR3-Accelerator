#importing libraries
import json
import os
import sys
import re

#setting where the arrows are defined
nr_path = sys.argv[1] + "/arrows-NR-0.sst"
lt_path = sys.argv[1] + "/arrows-LT-1.sst"
cn_path = sys.argv[1] + "/arrows-CN-2.sst"
ep_path = sys.argv[1] + "/arrows-EP-3.sst"

#Hash table for storing arrows
arrows_db = {}

#NR-0 arrows
direction = "positive"
group = "NR"
with open(nr_path, "r") as file:
    for line in file:#iterating over lines
        if "(" in line:
            arrow = line[line.find("(") + 1 : line.find(")")]##extracting the arrow syntax
            meaning = line[:line.find("(")].strip()#extracting the arrow meaning
            arrows_db[arrow] = {
                "meaning": meaning,
                "direction": direction,
                "group": group
            }

#LT-1 arrows
direction = "positive"
group = "LT"
with open(lt_path, "r") as file:
    for line in file:#iterating over lines
        if "+" in line:
            arrow = line[line.find("(") + 1 : line.find(")")]##extracting the arrow syntax
            meaning = line[line.find("+") + 1:line.find("(")].strip()#extracting the arrow meaning
            direction = "positive"#first arrow is always positive
            arrows_db[arrow] = {
                "meaning": meaning,
                "direction": direction,
                "group": group
            }
            pos_arrow_end = line.find(")")#end position of positive arrow extraction
            arrow = line[line.find("(", pos_arrow_end) +1 : line.find(")", pos_arrow_end+1) ]#instance of starting search for the negative arrow
            meaning = line[line.find("-" , pos_arrow_end) +1:line.find("(" , pos_arrow_end)].strip()#extracting the arrow meaning
            direction = "negative"#second arrow is always negative
            arrows_db[arrow] = {
                "meaning": meaning,
                "direction": direction,
                "group": group
            }

#CN-2 arrows
direction = "positive"
group = "CN"
with open(cn_path, "r") as file:
    for line in file:#iterating over lines
        if "+" in line:
            arrow = line[line.find("(") + 1 : line.find(")")]##extracting the arrow syntax
            meaning = line[line.find("+") + 1:line.find("(")].strip()#extracting the arrow meaning
            direction = "positive"#first arrow is always positive
            arrows_db[arrow] = {
                "meaning": meaning,
                "direction": direction,
                "group": group
            }
            pos_arrow_end = line.find(")")#end position of positive arrow extraction
            arrow = line[line.find("(", pos_arrow_end) +1 : line.find(")", pos_arrow_end+1) ]#instance of starting search for the negative arrow
            meaning = line[line.find("-" , pos_arrow_end) +1:line.find("(" , pos_arrow_end)].strip()#extracting the arrow meaning
            direction = "negative"#second arrow is always negative
            arrows_db[arrow] = {
                "meaning": meaning,
                "direction": direction,
                "group": group
            }

#EP-3 arrows
direction = "positive"
group = "EP"
with open(ep_path, "r") as file:
    for line in file:#iterating over lines
        if "+" in line:
            arrow = line[line.find("(") + 1 : line.find(")")]##extracting the arrow syntax
            meaning = line[line.find("+") + 1:line.find("(")].strip()#extracting the arrow meaning
            direction = "positive"#first arrow is always positive
            arrows_db[arrow] = {
                "meaning": meaning,
                "direction": direction,
                "group": group
            }
            pos_arrow_end = line.find(")")#end position of positive arrow extraction
            arrow = line[line.find("(", pos_arrow_end) +1 : line.find(")", pos_arrow_end+1) ]#instance of starting search for the negative arrow
            meaning = line[line.find("-" , pos_arrow_end) +1:line.find("(" , pos_arrow_end)].strip()#extracting the arrow meaning
            direction = "negative"#second arrow is always negative
            arrows_db[arrow] = {
                "meaning": meaning,
                "direction": direction,
                "group": group
            }

# Parsing notes for the knowledge graph building

#function for getting the termination of a single note in a line
def find_next_delimiter(line, start):
    positions = [
        line.find("(", start),
        line.find(".", start),
        line.find(",", start)
    ]

    positions = [p for p in positions if p != -1]

    if not positions:
        return len(line)

    return min(positions)

#Dictionary for storing notes
notes_dict = {}
notes_id = 0
notes_file_path = sys.argv[2] # n4l file path
First_node = True # for getting the first appearing source per line
notes_context = "" #for indicating which context the notes belong to 
notes_chapter = "" #for indicating which chapter the notes belong to 
#creating the translated version of the notes
file_opened = False #for preventing overwriting for multi chapter files
#Creating translated version of the notes
dir_notes = "dir_notes"
notes_line = ""
First_visit = True

if not os.path.exists(dir_notes):
    os.makedirs(dir_notes)


with open(notes_file_path, "r") as file:
    for line in file:#iterating over lines for getting the building-graph notes
        stripped_line = line.lstrip() #removing any white space before the actual characters
        if stripped_line.startswith("#") or stripped_line.startswith("//"):#checking line is not commented out
            continue

        #extracting the chapter
        if stripped_line.strip().startswith("-"):
            notes_chapter = stripped_line[1:].strip() 
            #handling the translation
            #first get the chapter title
            if(not file_opened):
                file_opened=True
                md_filename = f"{os.path.splitext(os.path.basename(notes_file_path))[0]}.md" # 
                md_file = open(f"./{dir_notes}/{md_filename}", "w") 
            md_file.write('# ' + notes_chapter + '\n\n')


        #extracting the context
        if stripped_line.strip().startswith("::"):
            notes_context = re.search(r":\s*:\s*(.*?)\s*:\s*:", stripped_line).group(1).strip()
            md_file.write('## ' + notes_context + '\n\n')

        #extracting arrows
        arrows_start = 0
        note_end = 0
        arrows_count = stripped_line.count("(") # getting number of relations per line (arrow1)
        
        if(arrows_count==0 and not(stripped_line.strip().startswith("::")) and not (stripped_line.strip().startswith("-"))):
            md_file.write(stripped_line + '\n')
        
        arrows_positions = [] # carrying positions of where arrows are
        while(arrows_count>0):#looping on existing arrows per line
            arrow = stripped_line[stripped_line.find("(", arrows_start) +1 : stripped_line.find(")", arrows_start+1)].strip()#extracting arrow
            if (stripped_line [arrows_start : stripped_line.find("(", arrows_start)].strip() == '"'):#checking if ditto is used and the previous source is repeated
                source = old_source #repeat
            else:
                source = stripped_line[arrows_start : stripped_line.find("(", arrows_start)].strip().replace("&period;", ".").replace("&comma;", ",")#new source
            if(First_node):
                old_source = source#update old_source
                First_node = False
            note_end = find_next_delimiter(stripped_line, stripped_line.find(")", arrows_start+1)+1)
            destination = stripped_line[stripped_line.find(")", arrows_start+1)+1 : note_end].strip().replace("&period;", ".").replace("&comma;", ",")
            #fill the dictionary
            notes_dict[notes_id] = {
                "source": source, 
                "arrow": arrow,
                "meaning": arrows_db[arrow]["meaning"],
                "direction": arrows_db[arrow]["direction"],
                "group": arrows_db[arrow]["group"],
                "destination": destination,
                "chapter": notes_chapter,
                "context": notes_context  
            }

            #storing the translated line
            if(First_visit):
                notes_line = f'{source} {arrows_db[arrow]["meaning"]} {destination}'# if first appearing arrow store as it is
                
            else:
                notes_line = notes_line + ' ' + arrows_db[arrow]["meaning"] + ' ' + destination

            First_visit=False
            
            arrows_start = stripped_line.find(")", arrows_start+1) +1#new arrow start after the processed one end
            arrows_count=arrows_count-1#decrement
            if(arrows_count==0):
                 md_file.write(notes_line +'.' +'\n')
            notes_id = notes_id + 1#increment ID
        First_node = True
        First_visit = True

    if file_opened:
        md_file.close()
    file_opened=False



#Exporting to JSON in ./json directory
json_dir = "json"

if not os.path.exists(json_dir):
    os.makedirs(json_dir)

json_name = os.path.splitext(os.path.basename(notes_file_path))[0] + ".json"
json_path = os.path.join(json_dir, json_name)

with open(json_path, "w") as file:
    json.dump(notes_dict, file, indent=4)


#writing the json list for the n4l files DB
# Extract only the filename
notes_file_name = os.path.basename(notes_file_path)

# Create ./json_list if it doesn't exist
json_list_dir = "./json_list"
os.makedirs(json_list_dir, exist_ok=True)

# Path to list.json
json_list_path = os.path.join(json_list_dir, "list.json")

# Create list.json if it doesn't exist
if not os.path.exists(json_list_path):
    with open(json_list_path, "w") as f:
        json.dump([], f, indent=2)

# Read the existing list
with open(json_list_path, "r") as f:
    notes_list = json.load(f)

# Add the filename only if it doesn't already exist
if notes_file_name not in notes_list:
    notes_list.append(notes_file_name)

    with open(json_list_path, "w") as f:
        json.dump(notes_list, f, indent=2)