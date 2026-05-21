import os
import sys

# Read the original compiler
with open("compile_report.py", "r", encoding="utf-8") as f:
    content = f.read()

# Modify the target files and output name
new_chapters = '    chapters = [\n        "IMAGE_AND_CHECKLIST_GUIDE.md"\n    ]'
content = content.split('    chapters = [')[0] + new_chapters + content.split('    ]')[1]

content = content.replace('BÁO_CÁO_THỰC_TẬP_HOÀN_CHỈNH.docx', 'HUONG_DAN_CHUAN_BI_HINH_ANH.docx')

# Write to a temporary compiler
with open("compile_guide.py", "w", encoding="utf-8") as f:
    f.write(content)

print("Generated compile_guide.py")
