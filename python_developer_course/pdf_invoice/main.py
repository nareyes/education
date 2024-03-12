import glob
import pandas as pd
from fpdf import FPDF
from pathlib import Path

# get filepaths
filepaths = glob.glob('invoices/*.xlsx')

for filepath in filepaths:
    # convert xlsx to dataframe
    df = pd.read_excel(filepath, sheet_name = 'Sheet 1')

    # extract invoice no
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
    pdf.cell(w = 50, h = 8, txt = f'Invoice No: {invoice_no}', align = 'L')
    pdf.cell(w = 50, h = 8, txt = f'Date: {invoice_date_formatted}', align = 'R')

    # output pdf
    pdf.output(f'pdfs/{filename}.pdf')