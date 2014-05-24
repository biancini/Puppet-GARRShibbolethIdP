(* Java.Security module for Augeas
 Author: Andrea Biancini <andrea.biancini@gmail.com>

 java.security is a standard INI File without sections.
*)

module JavaSecurity =
  autoload xfm

  let comment   = IniFile.comment IniFile.comment_re IniFile.comment_default
  let sep       = IniFile.sep IniFile.sep_re IniFile.sep_default
  let empty     = IniFile.empty

  let setting   = IniFile.entry_re
  let title     = IniFile.title ( IniFile.record_re - ".anon" )
  let entry     = IniFile.entry setting sep comment
  let record    = IniFile.record title entry
  let record_anon = [ label ".anon" . ( entry | empty )+ ]
  let lns       = record_anon | record*

  let filter = (incl "/usr/lib/jvm/*/jre/lib/security/java.security") . Util.stdexcl
  let xfm = transform lns filter
  