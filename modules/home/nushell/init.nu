use std/dirs

def ssh-connect [
  domain_name: string,
  ...prog: string,
] : {
  wezterm connect $"SSHMUX:($domain_name)" ...$prog
}

def get-devtool-recipe [
  path: path,
] : {
  $path | path split | skip until { |x| $x == "sources" } | skip 1 | first
}

def devtool-current [
  ...commands: string,
] : {
  devtool ...$commands $"(get-devtool-recipe pwd)"
}
