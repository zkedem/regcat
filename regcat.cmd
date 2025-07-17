<!-- :: Batch file section
@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
SET "filename=CON"
SET "filelist= "
ECHO %CMDCMDLINE% | findstr /R /C:"%COMSPEC%" /C:"/[Cc]" /C:"%~dpf0" 1>NUL 2>NUL
IF ERRORLEVEL 1 ( :: Command line mode
	SET "needshelp=0"
	IF "%~1" == "" SET /A "needshelp=1"
	IF "%~1" == "/?" SET /A "needshelp|=1"
	IF !needshelp! NEQ 0 ( :: If no arguments or /? as only argument
		ECHO Concatenates Windows Registry files to a single file. 1>&2
		ECHO. 1>&2
		ECHO %0 file1.reg file2.reg ... [/O:filename] 1>&2
		ECHO %0 /A 1>&2
		ECHO %0 /R 1>&2
		ECHO. 1>&2
		ECHO     file1.reg    An input file. 1>&2
		ECHO     /O:filename  Output to filename. 1>&2
		ECHO     /A           Add "Concatenate" to File Explorer context menu. 1>&2
		ECHO     /R           Remove "Concatenate" from File Explorer context menu. 1>&2
	) ELSE IF "%~1" == "/R" ( :: Remove from context menu
		reg DELETE HKCU\Software\Classes\regfile\shell\Concatenate /f 1>NUL 2>NUL
		ECHO Removed "Concatenate" from File Explorer context menu. 1>&2
		(CALL )
	) ELSE IF "%~1" == "/A" ( :: Add to context menu
		reg ADD HKCU\Software\Classes\regfile\shell\Concatenate\command /ve /d "\"%~dpf0\" \"%%1\"" /f 1>NUL 2>NUL
		ECHO Added "Concatenate" to File Explorer context menu. 1>&2
		(CALL )
	) ELSE (
		FOR %%a IN (%*) DO (
			SET "argument=%%a"
			IF NOT !argument:/O:^=! == !argument! ( :: Set output file
				SET "filename=!argument:/O:=!"
			) ELSE ( :: Add to list of input files
				SET "filelist=!filelist!!argument! "
			)
		)
		ECHO Windows Registry Editor Version 5.00 > "!filename!"
		TYPE !filelist! 2>NUL | findstr /R /V /C:"^Windows Registry Editor Version 5\.00$" >> "!filename!"
	)
) ELSE ( :: GUI operation
	IF NOT "%~2" == "" ( :: Drag-and-drop mode
		SET "htaargs=%*"
	) ELSE ( :: Context menu mode
		FOR /F "usebackq delims=" %%a IN (`mshta "%~f0" /U`) DO SET "uuid=%%a"
		COPY "%~1" "%TMP%\!uuid!.rgc" > NUL
		SET "htaargs=/D:"%TMP%^" /E /S:2 /X:rgc"
	)
	START /B mshta "%~f0" !htaargs!
)
ENDLOCAL
GOTO :EOF
-->
<!-- HTML application section -->
<html>
	<head>
		<hta:application id="app" border="none" showInTaskBar="no">
		<script language="JScript">
			var False = 0;
			var True = 1;
			(function() {
				var chars = app.commandLine.replace(/^ +| +$/g, "").split("");
				var cutArg = true;
				window.argv = [""];
				for (var i = 0; i < chars.length; i++) {
					if (chars[i] == " " && cutArg) {
						argv.push("");
					} else {
						if (chars[i] == "\"") {
							cutArg = !cutArg;
						}
						argv[argv.length - 1] += chars[i];
					}
				}
			})();
			onerror = function(message) {
				alert(message);
				close();
			};
			onload = function() {
				var ForReading = 1;
				var TristateUseDefault = -2;
				var fso = new ActiveXObject("Scripting.FileSystemObject");
				var UUIDRequested = false;
				var seconds = 0;
				var preamble = "Windows Registry Editor Version 5.00";
				var content = preamble + "\r\n";
				var directory = null;
				var eraseWhenDone = false;
				var extension = "";
				var fileList = [];
				function generateUUID() {
					var tl = new ActiveXObject("Scriptlet.TypeLib");
					fso.GetStandardStream(1).WriteLine(tl.GUID.replace(/[{}]/g, ""));
					close();
				}
				function zeroPad(n, size) {
					if (size == undefined) {
						size = 2;
					}
					return new Array(Math.max(0, size - n.toString().length + 1)).join("0") + n;
				}
				function xmlTime(d) {
					var timeString = "";
					timeString += zeroPad(d.getFullYear(), 4) + "-";
					timeString += zeroPad(d.getMonth() + 1) + "-";
					timeString += zeroPad(d.getDate()) + "T";
					timeString += zeroPad(d.getHours()) + ":";
					timeString += zeroPad(d.getMinutes()) + ":";
					timeString += zeroPad(d.getSeconds());
					return timeString;
				}
				function scheduleAsTask() {
					var TriggerTypeTime = 1;
					var ActionTypeExec = 0;
					var service = new ActiveXObject("Schedule.Service");
					service.Connect();
					var rootFolder = service.GetFolder("\\");
					var taskDefinition = service.NewTask(0);
					var trigger = taskDefinition.Triggers.Create(TriggerTypeTime);
					var startTime = Date.now() + seconds * 1000;
					var action = taskDefinition.Actions.Create(ActionTypeExec);
					taskDefinition.Principal.LogonType = 3;
					taskDefinition.Settings.Enabled = True;
					taskDefinition.Settings.StartWhenAvailable = True;
					taskDefinition.Settings.Hidden = False;
					taskDefinition.Settings.DeleteExpiredTaskAfter = "PT0S";
					trigger.StartBoundary = xmlTime(new Date(startTime));
					trigger.EndBoundary = xmlTime(new Date(startTime + 1000));
					trigger.Id = "TimeTriggerId";
					trigger.Enabled = True;
					action.Path = "%COMSPEC%";
					action.Arguments = "/C START \"\" mshta.exe " + argv[0];
					for (var i = 1; i < argv.length; i++) {
						var argument = argv[i];
						if (argument.substring(0, "/S:".length) != "/S:") {
							action.Arguments += " " + argument;
						}
					}
					rootFolder.RegisterTaskDefinition(fso.GetBaseName(argv[0]), taskDefinition, 6, "", "", 3);
					close();
				}
				function checkLength(a) {
					if (a.length < 1) {
						throw new Error("You must specify at least one file.");
					}
				}
				function consumeFile(fileHandle) {
					var text = fileHandle.ReadAll();
					if (text.search("\r") == -1 || text.search("\n") == -1) {
						text = text.replace(/[\r\n]/g, "\r\n");
					}
					if (text.substring(text.length - 2) != "\r\n") {
						text += "\r\n";
					}
					content += text.replace(preamble + "\r\n", "");
					fileHandle.Close();
				}
				function finish() {
					document.write(content);
					document.execCommand("saveAs", true, ".txt");
					close();
				}
				function fileMode() {
					checkLength(fileList);
					for (var i = 0; i < fileList.length; i++) {
						var fileHandle = fso.OpenTextFile(fileList[i], ForReading, False, TristateUseDefault);
						consumeFile(fileHandle);
					}
					finish();
				}
				function directoryMode() {
					var directoryHandle = fso.GetFolder(directory);
					var allFiles = directoryHandle.Files;
					var files = [];
					for (var e = new Enumerator(allFiles); !e.atEnd(); e.moveNext()) {
						var currentFile = e.item();
						var extensionName = fso.GetExtensionName(currentFile.Path);
						if (extensionName.substring(extensionName.length - extension.length) == extension) {
							files.push(currentFile);
						}
					}
					checkLength(files);
					for (var i = 0; i < files.length; i++) {
						var fileHandle = files[i].OpenAsTextStream(ForReading, TristateUseDefault);
						consumeFile(fileHandle);
						if (eraseWhenDone) {
							files[i].Delete(True);
						}
					}
					finish();
				}
				resizeTo(0, 0);
				for (var i = 1; i < argv.length; i++) {
					if (argv[i].substring(0, "/D:".length) == "/D:") {
						directory = argv[i].replace("/D:", "").replace(/^"|"$/g, "");
					} else if (argv[i].substring(0, "/E".length) == "/E") {
						eraseWhenDone = true;
					} else if (argv[i].substring(0, "/S:".length) == "/S:") {
						seconds = Number(argv[i].replace("/S:", ""));
					} else if (argv[i].substring(0, "/U".length) == "/U") {
						UUIDRequested = true;
					} else if (argv[i].substring(0, "/X:".length) == "/X:") {
						extension = argv[i].replace("/X:", "").replace(/^"|"$/g, "");
					} else {
						fileList.push(argv[i].replace(/^"|"$/g, ""));
					}
				}
				if (UUIDRequested) {
					generateUUID();
				} else if (seconds > 0) {
					scheduleAsTask();
				} else if (directory == null) {
					fileMode();
				} else {
					directoryMode();
				}
			};
		</script>
	</head>
	<body></body>
</html>