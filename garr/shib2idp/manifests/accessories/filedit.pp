define delete_lines($file, $pattern) {
   exec { "sed -i -r -e '/$pattern/d' $file":
      onlyif => "grep -E '$pattern' '$file'",
   }
}

define replace_lines($file, $pattern, $replace) {
   exec { "sed -i -r -e 's/$pattern/$replace/' $file":
      onlyif => "grep -E '$pattern' '$file'",
   }
}