<?php
session_start();

function checkPOSTvalue($key, $regexp, $showvalue=false) {
	$tmpvalue = $_POST[$key];
	if (preg_match($regexp, $tmpvalue)) return $tmpvalue;

	if ($showvalue) exit("Error with the $key paramenter provided: " . $_POST[$key]);
	else exit("Error with the $key parameter provided.");
}

//$pwd_regexp = '/^(?=.{8,})(?=.*[a-z])(?=.*[A-Z])(?=.*[\d])(?=.*[\W_]).*$/';
$pwd_regexp = '/^[a-zA-Z\d\W_]*$/';

$basedn = checkPOSTvalue('base', '/^dc=[\w-]+(,\s?dc=[\w-]+)*$/', true);
$dn = "ou=people," . $basedn;

$username = checkPOSTvalue('username', '/^[a-zA-Z0-9_\-\.]{5,30}$/', true);
$new_password = checkPOSTvalue('newpassword1', $pwd_regexp, false);

$user_dn = "uid=" . $username . "," . $dn;

$action = checkPOSTvalue('action', '/^admin|user$/', true);
if ($action == 'admin') {
        $connuser = "cn=admin," . $basedn;
        $connpasswd = checkPOSTvalue('adminpw', $pwd_regexp, false);
        $command = "/usr/bin/ldappasswd -x -D \"$connuser\" -x \"$user_dn\" -w $connpasswd -s $new_password";
} else {
        $connuser = "uid=" . checkPostvalue('username', '/^[a-zA-Z\d_\-\.]*$/', true) . "," . $dn;
        $connpasswd = checkPOSTvalue('oldpassword', $pwd_regexp, false);
        $command = "/usr/bin/ldappasswd -x -D \"$connuser\" -x \"$user_dn\" -w $connpasswd -a $connpasswd -s $new_password";
}

$output = array();
$return_var = -1;
exec(escapeshellcmd($command), $output, $return_var);

if ($return_var == 0) {
	$_SESSION['pw_message'] = $user_dn;
	header("Location: changepw.php");
}
else {
	if (isset($_SESSION['pw_message'])) unset($_SESSION['pw_message']);
	echo "There was a problem changing your password, please call IT for help ($return_var).";
        echo "<br/>";
	var_dump($output);
}


/*
$ds = ldap_connect("localhost", 389) or die("Could not connect to $ldaphost");
if ($ds) {
        ldap_set_option($ds, LDAP_OPT_PROTOCOL_VERSION, 3);

        $r = ldap_bind($ds, $connuser, $connpasswd);
        if(!$r) die("ldap_bind failed<br>");

        $filter = "uid=" . $username;
        $ldap_result = ldap_list($ds, $dn, $filter);
        $info = ldap_get_entries($ds, $ldap_result);

        //print "<pre>";
        //print_r($info); die();
        //print "</pre>";

        if ($info['count'] == 1) {
                //$userpassword = "{MD5}" . md5($new_password);
                $userpassword = $new_password;
                $userdata = array("userpassword" => array(0 => $userpassword));
                $result = ldap_mod_replace($ds, $user_dn, $userdata);

                if ($result) header("Location: changepw.php");
                else echo "There was a problem changing your password, please call IT for help";
        } else {
                echo "Invalid Password.";
        }

        ldap_close($ds);
} else {
        echo "Unable to connect to LDAP server.";
}
*/

?>
