# Package

version     = "0.0.0"
author      = "levshx"
description = "Critic game engine editor"
license     = "MIT"

# Deps

requires "nim >= 1.6.0"
requires "nimgl >= 1.3.2"

task test, "build & run app":
  exec("nim c editor.nim")
  withDir "bin":
    exec "./editor.exe"

task gamedll,"buildGAME":
  exec("nim c editor.nim")
  