; NSIS installer for Fognitix (Windows)
; Build staging layout with `cmake --install build/windows-release --prefix dist` then adjust paths below.

!define PRODUCT_NAME "Fognitix"
!define PRODUCT_VERSION "0.1.0"
!define OUTFILE "Fognitix_Setup_${PRODUCT_VERSION}.exe"

Name "${PRODUCT_NAME}"
OutFile "${OUTFILE}"
InstallDir "$PROGRAMFILES64\${PRODUCT_NAME}"
RequestExecutionLevel admin

Page directory
Page instfiles

Section "Install"
    SetOutPath "$INSTDIR"
    ; Package full staged runtime tree from cmake install prefix.
    File /r /nonfatal "..\dist\bin\*.*"
    File /r /nonfatal "..\dist\assets\*.*"
    File /r /nonfatal "..\dist\PNG\*.*"
    WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

Section "Uninstall"
    Delete "$INSTDIR\Uninstall.exe"
    RMDir /r "$INSTDIR\platforms"
    RMDir /r "$INSTDIR\styles"
    RMDir /r "$INSTDIR\imageformats"
    RMDir /r "$INSTDIR\iconengines"
    RMDir /r "$INSTDIR\multimedia"
    RMDir /r "$INSTDIR\networkinformation"
    RMDir /r "$INSTDIR\tls"
    RMDir /r "$INSTDIR\qml"
    RMDir /r "$INSTDIR\assets"
    RMDir /r "$INSTDIR\PNG"
    Delete "$INSTDIR\*.dll"
    Delete "$INSTDIR\*.exe"
    RMDir "$INSTDIR"
SectionEnd
