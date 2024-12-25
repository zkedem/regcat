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

## License
regcat is licensed under the GNU General Public License v3.0.
