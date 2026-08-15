Unicode true

!ifndef VERSION
  !define VERSION "0.1.0-rc.5"
!endif
!ifndef DIST_OUT
  !define DIST_OUT "deepseek-harness-${VERSION}-windows-setup.exe"
!endif

!define APP_NAME "DeepSeek Harness 桌面端"
!define APP_NAME_EN "DeepSeek Harness"

Name "${APP_NAME}"
OutFile "${DIST_OUT}"
InstallDir "$PROGRAMFILES64\DeepSeek Harness"
InstallDirRegKey HKCU "Software\DeepSeekHarnessDesktop" "InstallDir"
RequestExecutionLevel admin
SetCompressor /SOLID lzma

!include "MUI2.nsh"

!define MUI_ICON "assets\icon.ico"
!define MUI_UNICON "assets\icon.ico"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "English"

Section "install" SecMain
  SetOutPath "$INSTDIR"
  File /r /x "*.cmd" /x "*.ps1" deploy\*.*
  File dsh-desktop.ps1
  File dsh.cmd
  File run-service.cmd
  File /r node\*.*
  File /oname=icon.ico assets\icon.ico

  WriteRegStr HKCU "Software\DeepSeekHarnessDesktop" "InstallDir" "$INSTDIR"
  WriteRegStr HKCU "Software\DeepSeekHarnessDesktop" "Version" "${VERSION}"
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  CreateDirectory "$SMPROGRAMS\DeepSeek Harness"
  CreateShortcut "$SMPROGRAMS\DeepSeek Harness\${APP_NAME}.lnk" \
    "$SYSDIR\WindowsPowerShell\v1.0\powershell.exe" \
    '-WindowStyle Hidden -ExecutionPolicy Bypass -File "$INSTDIR\dsh-desktop.ps1"' \
    "$INSTDIR\icon.ico"
  CreateShortcut "$DESKTOP\${APP_NAME}.lnk" \
    "$SYSDIR\WindowsPowerShell\v1.0\powershell.exe" \
    '-WindowStyle Hidden -ExecutionPolicy Bypass -File "$INSTDIR\dsh-desktop.ps1"' \
    "$INSTDIR\icon.ico"
  CreateShortcut "$SMPROGRAMS\DeepSeek Harness\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
SectionEnd

Section "Uninstall"
  Delete "$SMPROGRAMS\DeepSeek Harness\${APP_NAME}.lnk"
  Delete "$SMPROGRAMS\DeepSeek Harness\Uninstall.lnk"
  RMDir "$SMPROGRAMS\DeepSeek Harness"
  Delete "$DESKTOP\${APP_NAME}.lnk"
  RMDir /r "$INSTDIR"
  DeleteRegKey HKCU "Software\DeepSeekHarnessDesktop"
SectionEnd
