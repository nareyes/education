"""
Script to convert multiple Excel invoices into PDF format.

Dependencies:
    - pandas
    - fpdf
    - pathlib

This script reads Excel files containing invoice data from a specified directory,
creates corresponding PDF files for each invoice, and adds necessary details like
invoice number, date, item details, total price, and company information.
"""

import glob
import pandas as pd
from fpdf import FPDF
from pathlib import Path

# get filepaths
filepaths = glob.glob('invoices/*.xlsx')


for filepath in filepaths:
    # extract invoice
    filename = Path(filepath).stem
    invoice_no = filename.split('-')[0]

    # extract date
    invoice_date = filename.split('-')[1:]
    invoice_date_formatted = '-'.join(invoice_date)

    # create blank pdf
    pdf = FPDF(orientation = 'P', unit = 'mm', format = 'A4')
    pdf.add_page()

    # add header
    pdf.set_font(family = 'Times', size = 16, style = 'B')
    pdf.cell(w = 50, h = 8, txt = f'Date: {invoice_date_formatted}', ln = 1)
    pdf.cell(w = 50, h = 8, txt = f'Invoice No: {invoice_no}', ln = 1)
    pdf.cell(w = 50, h = 8, ln = 1)

    # convert xlsx to dataframe and extract column names
    df = pd.read_excel(filepath, sheet_name = 'Sheet 1')
    df_cols = df.columns
    df_cols = [col.replace('_', ' ').title() for col in df_cols]

    # add table header
    pdf.set_font(family = 'Times', size = 10, style = 'B')

    pdf.cell(w = 35, h = 8, txt = df_cols[0], border = 1)
    pdf.cell(w = 50, h = 8, txt = df_cols[1], border = 1)
    pdf.cell(w = 35, h = 8, txt = df_cols[2], border = 1)
    pdf.cell(w = 35, h = 8, txt = df_cols[3], border = 1)
    pdf.cell(w = 35, h = 8, txt = df_cols[4], border = 1, ln = 1)

    # add table values
    for index, row in df.iterrows():
        pdf.set_font(family = 'Times', size = 10)
        pdf.set_text_color(80, 80, 80)

        pdf.cell(w = 35, h = 8, txt = str(row['product_id']), border = 1)
        pdf.cell(w = 50, h = 8, txt = str(row['product_name']), border = 1)
        pdf.cell(w = 35, h = 8, txt = str(row['amount_purchased']), border = 1)
        pdf.cell(w = 35, h = 8, txt = str(row['price_per_unit']), border = 1)
        pdf.cell(w = 35, h = 8, txt = str(row['total_price']), border = 1, ln = 1)
    
    # add sum of total price
    sum_price = df['total_price'].sum()

    pdf.set_font(family = 'Times', size = 10, style = 'B')
    pdf.cell(w = 35, h = 8, txt = '', border = 1)
    pdf.cell(w = 50, h = 8, txt = '', border = 1)
    pdf.cell(w = 35, h = 8, txt = '', border = 1)
    pdf.cell(w = 35, h = 8, txt = '', border = 1)
    pdf.cell(w = 35, h = 8, txt = str(sum_price), border = 1, ln = 1)
    pdf.cell(w = 35, h = 8, ln = 1)

    # add footer
    pdf.set_font(family = 'Times', size = 14, style = 'B')
    pdf.set_text_color(0, 0, 0)
    pdf.cell(w = 50, h = 8, txt = f'Total Invoice Price: ${sum_price}', ln = 1)
    pdf.cell(w = 40, h = 8, txt = 'Company Name')
    pdf.image(w = 10, name = 'pythonhow.png')

    # output pdf
    pdf.output(f'pdfs/{filename}.pdf')