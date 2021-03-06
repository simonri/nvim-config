@ECHO OFF

SET APPDATA_PATH=%LocalAppData%\nvim
SET COC_PATH=%UserProfile%\.config\coc
SET NVIM_PATH=%UserProfile%\.config\nvim

echo Installing Neovim config...

:CHECK_PIP
WHERE pip 2>NUL >NUL && ECHO Pip already installed && GOTO :CHECK_NODE_NEOVIM
ECHO Please install pip && GOTO :EOF

:CHECK_NODE_NEOVIM
WHERE node 2>NUL >NUL && ECHO Node already installed && goto :CHECK_PYNVIM
ECHO Please install neovim && GOTO :EOF

:CHECK_PYNVIM
2>NUL pip list | findstr pynvim && ECHO Pynvim already installed, moving on... && GOTO :CHECK_CTAGS
ECHO Please install pynvim && GOTO :EOF

:CHECK_CTAGS
WHERE ctags 2>NUL >NUL && ECHO Ctags already installed && goto :MOVE_OLD_NVIM_DIR
ECHO Please install ctags
ECHO https://github.com/universal-ctags/ctags-win32/ && GOTO :EOF

:MOVE_OLD_NVIM_DIR
IF EXIST %NVIM_PATH% (
  RMDIR /Q/S "%NVIM_PATH%"
)
MKDIR "%NVIM_PATH%"

:MOVE_OLD_APPDATA_DIR
IF EXIST %APPDATA_PATH% (
  RMDIR /Q/S "%APPDATA_PATH%"
)
MKDIR "%APPDATA_PATH%"

:MOVE_OLD_COC_DIR
IF EXIST %COC_PATH% (
  RMDIR /Q/S "%COC_PATH%"
)
MKDIR "%COC_PATH%"

:CLONE_CONFIG
ECHO Cloning configuration
git clone https://github.com/simonri/nvim-config.git "%NVIM_PATH%"

:INSTALL_PLUGINS
WHERE nvim 2>NUL >NUL || GOTO :EOF

ECHO Add fake init file
MOVE "%NVIM_PATH%\appdata.init.vim" "%APPDATA_PATH%\" >NUL
REN "%APPDATA_PATH%\appdata.init.vim" "init.vim" >NUL

MOVE "%NVIM_PATH%\autoload" "%APPDATA_PATH%\autoload" >NUL

ECHO Move tmp init to NVIM_PATH
REN "%NVIM_PATH%\init.vim" "init.vim.tmp" >NUL
MOVE "%NVIM_PATH%\utils\init.vim" "%NVIM_PATH%" >NUL

ECHO Installing plugins
nvim --headless +PlugInstall +qall

MOVE "%NVIM_PATH%\init.vim" "%NVIM_PATH%\utils" >NUL
REN "%NVIM_PATH%\init.vim.tmp" "init.vim" >NUL

:INSTALL_COC_EXTENSIONS
MOVE "%NVIM_PATH%\coc-settings.json" "%APPDATA_PATH%"
MKDIR "%NVIM_PATH%\..\coc\extensions" >NUL
CD "%NVIM_PATH%\..\coc\extensions"
npm init -y
npm install coc-explorer coc-snippets coc-json coc-actions --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod