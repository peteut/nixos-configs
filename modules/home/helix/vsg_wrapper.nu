#!/usr/bin/env -S nu --stdin

def main [] {
  let tmpFile = (mktemp -t --suffix .vhd)
    $in | save -f $tmpFile
    mut cmd = ["vsg" "-of" "syntastic"]
    if $env.VSG_CONFIG? != null and ($env.VSG_CONFIG | path exists) {
      $cmd ++= ["-c" $"($env.VSG_CONFIG | path expand)"]
    }
  $cmd = ["--fix" $tmpFile]
  run-external ...$cmd | ignore
  open --raw $tmpFile | print
  rm $tmpFile
}
