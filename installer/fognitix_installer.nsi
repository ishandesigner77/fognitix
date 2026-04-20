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
    ; Pack additional runtime files (Qt platforms, QML, shaders, assets) from your staging prefix as needed.
    File /nonfatal "..\dist\bin\Fognitix.exe"
    WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

Section "Uninstall"
    Delete "$INSTDIR\Uninstall.exe"
    Delete "$INSTDIR\Fognitix.exe"
    RMDir "$INSTDIR"
SectionEnd
