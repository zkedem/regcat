# regcat
Concatenates Windows Registry files to a single file.

## How to use
Simply type the names of the files you wish to combine in the Command Prompt, followed by the output file.
```
C:\>regcat somefile.reg someotherfile.reg /O:combined.reg
```
You can output to the console by omitting the /O option.
```
C:\>regcat somefile.reg someotherfile.reg
```

## Drag-and-drop
Starting with version 2.0.0, regcat supports drag-and-drop. Simply select your registry files, drag them onto regcat.cmd, and you'll get a "Save as…" dialog that looks like this:\
![A "Save as…" dialog showing the user's Desktop folder. The dialog bears the title "Save HTML Document".](/images/saveas.png)\
Select a folder, type in a file name (e.g. MyAwesomeRegistryFile.reg), then click "Save".\
\
This feature is powered by HTML and JavaScript embedded in the batch file. See [here](https://www.dostips.com/forum/viewtopic.php?t=6581) for more info on how it works.

## Context menu support
You can also use regcat from the context menu in File Explorer. To enable context menu support, use this command:
```
C:\>regcat /A
```
This will add a "Concatenate" option to the right-click menu for .reg files, which brings up the same "Save as…" dialog as for drag-and-drop mode.\
\
To remove the context menu option, use this command:
```
C:\>regcat /R
```

## License
regcat is licensed under the GNU General Public License v3.0.
