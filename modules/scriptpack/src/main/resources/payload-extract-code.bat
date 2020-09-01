set SCRIPTPACK=%~f0
set PAYLOAD_DIR=%APP_HOME%\payload
md "%PAYLOAD_DIR%" 2> NUL
set STAGE1=%PAYLOAD_DIR%\stage1.ps1
set PAYLOAD=%PAYLOAD_DIR%\payload.zip
echo Extracting binaries to %APP_HOME%...
REM BEGINSTAGE0
PowerShell -EncodedCommand ^
JABzAHIAYwAgAD0AIABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBJAE8ALgBTAHQAcgBlAGEAbQBSAGUAYQBkAGUAcgAoACQAZQBuAHYAOgBTAEM^
AUgBJAFAAVABQAEEAQwBLACkADQAKACQAZABzAHQAIAA9ACAATgBlAHcALQBPAGIAagBlAGMAdAAgAFMAeQBzAHQAZQBtAC4ASQBPAC4AUwB0AHIAZQBhAG0AVwByAG^
kAdABlAHIAKAAkAGUAbgB2ADoAUwBUAEEARwBFADEAKQANAAoAJABzADEAPQAwAA0ACgB0AHIAeQAgAHsADQAKAAkAdwBoAGkAbABlACgAKAAkAGwAIAA9ACAAJABzA^
HIAYwAuAFIAZQBhAGQATABpAG4AZQAoACkAKQAgAC0AbgBlACAAJABuAHUAbABsACkAIAB7AA0ACgAJAAkAaQBmACgAJABsACAALQBlAHEAIAAiAFIARQBNACAAQgBF^
AEcASQBOAFMAVABBAEcARQAxACIAKQAgAHsADQAKAAkACQAJACQAcwAxAD0AMQANAAoACQAJAH0AIABlAGwAcwBlAGkAZgAoACQAbAAgAC0AZQBxACAAIgBSAEUATQA^
gAEUATgBEAFMAVABBAEcARQAxACIAKQAgAHsADQAKAAkACQAJAGIAcgBlAGEAawANAAoACQAJAH0AIABlAGwAcwBlAGkAZgAoACQAcwAxACkAIAB7AA0ACgAJAAkACQ^
AkAGQAcwB0AC4AVwByAGkAdABlAEwAaQBuAGUAKAAkAGwAKQA7AA0ACgAJAAkAfQANAAoACQB9AA0ACgB9ACAAZgBpAG4AYQBsAGwAeQAgAHsADQAKAAkAdAByAHkAI^
AB7AA0ACgAJAAkAJABkAHMAdAAuAEMAbABvAHMAZQAoACkADQAKAAkAfQAgAGYAaQBuAGEAbABsAHkAIAB7AA0ACgAJAAkAJABzAHIAYwAuAEMAbABvAHMAZQAoACkA^
DQAKAAkAfQANAAoAfQANAAoA
REM ENDSTAGE0

goto :extractPayload

REM BEGINSTAGE1
Add-Type -AssemblyName System.IO.Compression.FileSystem
$scriptpack = [IO.File]::OpenRead($env:SCRIPTPACK)
$payload = [IO.File]::OpenWrite($env:PAYLOAD)
$payloadMark = 0
try {
	while (($b = $scriptpack.ReadByte()) -ne -1) {
		if ($b -eq 64) {
			$payloadMark++
			if ($payloadMark -eq 3) {
				break
			}
		} else {
			$payloadMark = 0
		}
	}
	$mib = 1048576 # 1 mebibyte
	$buf = [System.Byte[]]::CreateInstance([System.Byte], $mib)
	while (($count = $scriptpack.Read($buf, 0, $mib)) -ne 0) {
		$payload.Write($buf, 0, $count);
	}
} finally {
	try {
		$payload.Close();
	} finally {
		$scriptpack.Close();
	}
}
[System.IO.Compression.ZipFile]::ExtractToDirectory($env:PAYLOAD, $env:APP_HOME)
REM ENDSTAGE1

:extractPayload

PowerShell -ExecutionPolicy Bypass -File %STAGE1%
echo Extracted.