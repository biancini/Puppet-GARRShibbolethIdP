(* IdPConfig module for Augeas
 Author: Andrea Biancini <andrea.biancini@gmail.com>

 All IdP configuration files are standard XML files.
*)

module IdPConfig =
  autoload xfm

  let lns       = Xml.lns

  let filter = (incl "/opt/shibboleth-idp/conf/*.xml") . Util.stdexcl
  let xfm = transform lns filter
