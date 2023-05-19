; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Ikuzain"
#define MyAppVersion "1.6"
#define MyAppPublisher "Ikuzain Group."
#define MyAppURL "https://easo.hezkuntza.net/es/inicio"
#define MyAppExeName "fwrtc.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{30B8EF83-F139-4CAE-B4C5-A55120591903}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
; Remove the following line to run in administrative install mode (install for all users.)
PrivilegesRequired=lowest
OutputDir=C:\Users\santi\dev\IKUZAIN\fwrtc_win\Installers
OutputBaseFilename=IkuzainSetup
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "C:\Users\santi\dev\IKUZAIN\fwrtc_win\build\windows\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\santi\dev\IKUZAIN\fwrtc_win\build\windows\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "C:\Users\santi\dev\IKUZAIN\fwrtc_win\build\windows\runner\Release\flutter_webrtc_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\santi\dev\IKUZAIN\fwrtc_win\build\windows\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\santi\dev\IKUZAIN\fwrtc_win\build\windows\runner\Release\geolocator_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\santi\dev\IKUZAIN\fwrtc_win\build\windows\runner\Release\libwebrtc.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\santi\dev\IKUZAIN\fwrtc_win\build\windows\runner\Release\platform_device_id_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\santi\dev\IKUZAIN\fwrtc_win\build\windows\runner\Release\msvcp140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\santi\dev\IKUZAIN\fwrtc_win\build\windows\runner\Release\vcruntime140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\santi\dev\IKUZAIN\fwrtc_win\build\windows\runner\Release\vcruntime140_1.dll"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}" ; IconFilename: "C:\Users\santi\dev\IKUZAIN\fwrtc_win\assets\app_icon.ico"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon ; IconFilename: "C:\Users\santi\dev\IKUZAIN\fwrtc_win\assets\app_icon.ico"


[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

