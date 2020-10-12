# Script Pack

Script Pack creates executable scripts for Windows and POSIX systems that contain arbitrary binary data (payload). The resulting scripts are completely self-contained. The script code of each script is mostly user-defined and the payload extracts itself.

### Creating POSIX scripts
Script Pack creates POSIX scripts using the standard approach for creating self-contained scripts by appending binary data at the end of a shell script. Script Pack supports creating scripts for the following operating systems: Linux, macOS, *BSD, Solaris, AIX, and HP-UX. The following limitation exists when creating scripts for Solaris, AIX, and HP-UX: the payload archive must be in the PAX format.

### Creating Windows scripts
Since the standard approach for creating POSIX scripts cannot be applied directly to Windows batch scripts, an innovative approach is used to achieve a behavior that is similar to a POSIX self-contained script. A two-stage PowerShell-assisted mechanism extracts binary data from the end of a batch script. The script consists of three parts:
- Initialization - user-defined code, which must initialize a variable with a pre-defined name whose value points to the location where to extract the payload. Command line argument handling should also be included in the initialization part of the script.
- Payload extract code - code that is automatically inserted into the script. When the payload extract code is executed, it extracts the payload from the script.
- Execution - user-defined code that uses the extracted payload. The code in the execution part of the script defines what the script should do with the extracted payload.

Input script examples are available for [Windows](modules/scriptpack/src/main/resources/example-input-script.bat) and [POSIX](modules/scriptpack/src/main/resources/example-input-script.sh).
A fully functional example is available at <https://github.com/SoftwareAG/scriptpack-consumer>

#### Limitations
The following issue occurs when appending binary data to the end of a batch script: if the script contains more than 512 null-bytes that are not separated by newline characters, or one or more null-bytes come right after a newline character, then `goto` statements do not work for labels that are above the `goto` statement. This prevents robust command line argument processing because a *goto-shift* loop cannot be created.

The following examples show a working script containing 512 null-bytes and a script containing 513 null-bytes that demonstrates the issue described above:
- [512null.bat](modules/scriptpack/src/main/resources/512null.bat)
- [513null.bat](modules/scriptpack/src/main/resources/513null.bat)

Executing the working 512null.bat script produces the following output:
```
> 512null.bat one two three
arg one
arg two
arg three
```
Executing the 513null.bat script that demonstrates the issue produces the following output:
```
> 513null.bat one two three
arg one
The system cannot find the batch label specified - processArgs
```

***

This code is provided as-is and without warranty or support. It does not constitute part of the Software AG product suite. Users are free to use, fork and modify it, subject to the license agreement. While Software AG welcomes contributions, we cannot guarantee to include every contribution in the master project.
