$src = New-Object System.IO.StreamReader($env:SCRIPTPACK)
$dst = New-Object System.IO.StreamWriter($env:STAGE1)
$s1=0
try {
	while(($l = $src.ReadLine()) -ne $null) {
		if($l -eq "REM BEGINSTAGE1") {
			$s1=1
		} elseif($l -eq "REM ENDSTAGE1") {
			break
		} elseif($s1) {
			$dst.WriteLine($l);
		}
	}
} finally {
	try {
		$dst.Close()
	} finally {
		$src.Close()
	}
}