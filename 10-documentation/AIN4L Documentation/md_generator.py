# ============================================================
    # Auto_N4L_2_Documentation
    # Author: Mohamed Khaled
    # GitHub: https://github.com/m7md5303
    # Copyright (C) 2026  Mohamed Khaled

    # This program is free software; you can redistribute it and/or modify
    # it under the terms of the GNU General Public License as published by
    # the Free Software Foundation; either version 2 of the License, or
    # (at your option) any later version.

    # This program is distributed in the hope that it will be useful,
    # but WITHOUT ANY WARRANTY; without even the implied warranty of
    # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    # GNU General Public License for more details.

    # You should have received a copy of the GNU General Public License along
    # with this program; if not, write to the Free Software Foundation, Inc.,
    # 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
# ============================================================

import re
import sys
import subprocess
import tqdm
from llama_cpp import Llama

chapter_name = sys.argv[1]
i=1
sep_lines = [None] * 11
ret_chap = []
chapter_title = ""
chapter_title_old = ""
file_opened = False #for preventing overwriting for multi chapter files
subprocess.run(["mkdir", "-p", "./../generated_md"])



while (len(sep_lines)>10):# checking there is still retrieved output from the DB
    retrieve_notes_cmd = ["./searchN4L", "\\notes", chapter_name, "\\limit", "1000", "\\pagenr", f'{i}']
    state = subprocess.run(retrieve_notes_cmd, capture_output=True, text=True)
    if(state.returncode):#error check
       print(f"Couldn't run...exit due to error...{state.stderr}")
       break
    else:
        i=i+1#iterating over pages
        ret_out = state.stdout
        sep_lines = ret_out.splitlines()
        if(len(sep_lines)>10): #if output caught then:
            lines = ret_out.splitlines()
            for line in lines:
                line = line.strip()
                if not line:
                    continue
                else :
                    #getting titles
                    ret_chap = re.match(r'^Title:\s*(.*)', line)
                    #making sure it is new title
                    if ret_chap and (ret_chap.group(1).strip() != chapter_title_old):
                        chapter_title = ret_chap.group(1).strip() 
                        if(not file_opened):#if first title open new file
                            md_filename = f"./../generated_md/{chapter_title.replace(' ', '_')}.md" # for the generated from LLM
                            md_filename_direct_Interpretation = f"{chapter_title.replace(' ', '_')}_direct_Interpretation.md"
                            md_file = open(f"./../generated_md/{md_filename_direct_Interpretation}", "w") 
                            file_opened = True
                        chapter_title_old = chapter_title
                        md_file.write('# ' + chapter_title + '\n')
                    #getting sections
                    sec_title = re.match(r'^Context:\s*(.*)', line)
                    if sec_title:
                        sec_title = sec_title.group(1).strip()
                        md_file.write('## ' + sec_title + '\n\n')
                    # getting raw notes with their human readable meaning
                    if re.match(r'^\[line \d+\]:', line):
                        note = re.sub(r'^\[line \d+\]:\s*', '', line)
                        note = re.sub(r'\((.*?)\)', r'\1', note)
                        md_file.write(note + "\n")
if file_opened:
    md_file.close()



#-------------------------------------------------------------------------------------#
# Adding the LLM Feature
#instantiating the local LLM
if (len(sys.argv) > 2 and sys.argv[2]):
    custom_prompt = sys.argv[2]
else:
    custom_prompt = None 
if file_opened:
    llm = Llama(
        model_path="./models/qwen2.5-3b-instruct-q4_k_m.gguf",
        n_ctx=4096,
        n_threads=8
    )

    long_scanned = 0
    chunk_size = 120#chunk size (if file is long)
    ret_chunks = 0
    ret_lines_tmp = []
    tmp_md_file = open(f'./../generated_md/{md_filename_direct_Interpretation}' , "r")
    new_md_file = open(md_filename , "w")
    new_md_file.write("**Disclaimer: The Documentation is AI-generated and may make mistakes**" + "\n" + "\n")
    for line in tmp_md_file: #looping on the static generated md lines
        ret_chunks = ret_chunks+1
        ret_lines_tmp.append(line)
        if(ret_chunks>=120):
            scanned = 0
            llm_input = "".join(ret_lines_tmp)
            ret_chunks=0
            ret_lines_tmp=[]
            messages=[
                {
                    "role": "system",
                    "content": "Your role is to take markdown lines analyze line by line and paraphrase them to be professional project documentation in paragraphs and meaningful titles. It is forbidden to change or remove or add any information to the givens. Avoid generic titles"
                }
            ]
            if (custom_prompt) :
                messages.append({
                     "role": "system",
                    "content": custom_prompt
                })
            messages.append({
                "role": "user",
                "content": f'{llm_input}'
            })
            output = llm.create_chat_completion(
            messages = messages,
            temperature=0,
            top_p=0.7
            )
            new_md_file.write(output["choices"][0]["message"]["content"] + "\n")
        else:
            scanned = 1
    #in case the notes weere less than one ocmplete chunk
    if (scanned):
            llm_input = "".join(ret_lines_tmp)
            ret_chunks=0
            ret_lines_tmp=[]
            messages=[
                {
                    "role": "system",
                    "content": "Your role is to take markdown lines analyze line by line and paraphrase them to be professional project documentation in paragraphs and meaningful titles. It is forbidden to change or remove or add any information to the givens. Avoid generic titles"
                }
            ]
            if (custom_prompt) :
                messages.append({
                     "role": "system",
                    "content": custom_prompt
                })
            messages.append({
                "role": "user",
                "content": f'{llm_input}'
            })
            output = llm.create_chat_completion(
            messages = messages,
            temperature=0,
            top_p=0.7
            )
            new_md_file.write(output["choices"][0]["message"]["content"] + "\n")
            
    new_md_file.close()
