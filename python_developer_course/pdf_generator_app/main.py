"""
Script to generate a PDF document with cover page and topics with multiple pages.

Dependencies:
    - fpdf: For PDF generation
    - pandas: For reading CSV file

The script reads data from a CSV file named 'topics.csv' with columns ['Topic', 'Pages'].
Each topic in the CSV file will have its own page(s) in the generated PDF.
"""

from fpdf import FPDF
import pandas as pd

# create blank pdf 
pdf = FPDF(orientation = 'P', unit = 'mm', format = 'A4')
pdf.set_auto_page_break(auto = False, margin = 0)


# import topics csv
df = pd.read_csv('topics.csv')


# create cover page
pdf.add_page()
pdf.set_font(family = 'Times', style = 'B', size = 36)


# get the dimensions of the page
page_width = pdf.w
page_height = pdf.h


# get the dimensions of the text
text_width = pdf.get_string_width("Python Developer Course Notes")
text_height = pdf.font_size


# calculate x and y coordinates for centering the text
x = (page_width - text_width) / 2
y = (page_height - text_height) / 2
pdf.text(x, y, "Python Developer Course Notes")


# add topics as pages starting on second page
for index, row in df.iterrows():
    # pdf.add_page()
    # pdf.set_font(family = 'Times', style = 'B', size = 24)
    # pdf.cell(w = 0, h = 12, txt = row['Topic'], align = 'L', ln = 1, border = 0)
    # pdf.line(x1 = 10, x2 = 200, y1 = 20, y2 = 20)

    for i in range(row['Pages']):
        pdf.add_page()
        pdf.set_font(family = 'Times', style = 'B', size = 24)
        pdf.set_text_color(0, 0, 0)
        pdf.cell(w = 0, h = 12, txt = row['Topic'] + ' (Page ' + str(i + 1) + ')', align = 'L', ln = 1, border = 0)
        pdf.line(x1 = 10, x2 = 200, y1 = 20, y2 = 20)

        # lines
        for y in range(30, 290, 10):
            pdf.line(x1 = 10, x2 = 200, y1 = y, y2 = y)

        # footer
        pdf.ln(260)
        pdf.set_font(family = 'Times', style = 'I', size = 8)
        pdf.set_text_color(180, 180, 180)
        pdf.cell(w = 0, h = 10, txt = row['Topic'], align = 'R')



# output pdf
pdf.output('test.pdf')