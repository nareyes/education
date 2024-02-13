import PySimpleGUI as gui

select_label = gui.Text('Select Files to Compress:')
select_input_box = gui.Input()
select_choose_button = gui.FilesBrowse('Choose')


destination_label = gui.Text('Select Destination Folder:')
destination_input_box = gui.Input()
destination_choose_button = gui.FolderBrowse('Choose')

compress_button = gui.Button('Compress')

window = gui.Window('File Compressor', layout = [
    [select_label, select_input_box, select_choose_button],
    [destination_label, destination_input_box, destination_choose_button],
    [compress_button]
])
window.read()
window.close()