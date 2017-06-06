# workon
Matlab function that allows the user to save / load a project. Workon saves the currently open files in the editor and the workspace variables (if they don't exceeed a threshold size, set by the user). Workon also allows the user to enter notes about the project, which are displayed when the workon project is opened.

# Details

Saves the files currently open and the workspace variables. If workspace
variables sum to greater than a threshold size (in Mb, see 'Settings'),
the user is flagged and given the option whether or not to save the
workspace variables (set this to your preferred size).

When creating a new workon file, the user is also prompted to enter a
note. For short notes, use 'workon add' (notes are entered in the command
line). For longer notes, use 'workon add long' (notes entered in a dialog
box).

To create a new workon file, use 'workon new'. The workon file is stored
as a hidden file in the curent directory.

'''workon new''        : Create new workon file
'''workon save''       : Update the workon field to reflect the currently open windows
''workon add''         : Add a new short note
'''workon add long''   : Add a new long note
'''workon remove n''   : Remove note n from the workon file, where n is an integer
'''workon view''       : View the workon notes
'''workon''            : Don't include an argument to just load the workon file
