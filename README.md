# Script Pack

Script Pack creates executable scripts for Windows and POSIX systems that contain arbitrary binary data (payload). The resulting scripts are completely self-contained:
- The script code is mostly user-defined
- The payload extracts itself

### POSIX scripts
Appending binary data at the end of a shell script is a well-known approach for creating self-contained scripts and the details don't need to be discussed. The same approach is used here.

### Windows scripts
The approach for POSIX cannot be applied directly to Windows batch scripts. So a clever trick was developed to achieve a behaviour similar to a POSIX self-contained script. A 2-stage powershell-assisted mechanism is used to extract binary data from the end of a batch script. The script is divided in 3 parts:
- Initialization - User-defined code which must initialize a variable with e pre-defined name and the value must be the location to extract the payload. Command line argument handling also goes here.
- Payload extract code - This code is automatically insterted into the script and when executed extracts the payload from the script.
- Execution - User-defined code that uses the already extracted payload in some way.

An input script example is available [here](modules/scriptpack/src/main/resources/example-input-script.bat).
A fully functional example is available at <https://github.com/SoftwareAG/scriptpack-consumer>

#### Limitations
Unfortunately there's an issue when appending binary data to the end of a batch script. If the script contains more than 512 null-bytes that are not separated by newline characters or one or more null-bytes come right after a newline character then `goto` statements do not work for labels that are above the `goto` statement. This prevents robust command line argument processing because a *goto-shift* loop cannot be created.

There are example scripts that demonstrate the issue. The scripts differ by only one byte.
- [512null.bat](modules/scriptpack/src/main/resources/512null.bat) - works
- [513null.bat](modules/scriptpack/src/main/resources/513null.bat) - does not

Executing the scripts produces the following output:
```
> 512null.bat one two three
arg one
arg two
arg three
```
```
> 513null.bat one two three
arg one
The system cannot find the batch label specified - processArgs
```

