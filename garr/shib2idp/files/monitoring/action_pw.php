<?php
session_start();

function checkPOSTvalue($key, $regexp) {
        $tmpvalue = $_POST[$key];
        if (preg_match($regexp, $tmpvalue)) return $tmpvalue;
        return false;
}

$error_message = false;

//$pwd_regexp = '/^(?=.{8,})(?=.*[a-z])(?=.*[A-Z])(?=.*[\d])(?=.*[\W_]).*$/';
$pwd_regexp = '/^[a-zA-Z\d\W_]*$/';

$basedn = checkPOSTvalue('base', '/^dc=[\w-]+(,\s?dc=[\w-]+)*$/', true);
$dn = "ou=people," . $basedn;

$username = checkPOSTvalue('username', '/^[a-zA-Z0-9_\-\.]{5,30}$/', true);
if ($username === false) {
        $error_message = "Error with the $key parameter provided.";
}
else {
        $new_password = checkPOSTvalue('newpassword1', $pwd_regexp, false);
        if ($new_password === false) {
                $error_message = array(
                        "en" => "Error with the $key parameter provided.",
                        "it" => "Errore con il parametro $key fornito."
                );
        }
}

if ($error_message === false) {
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

        $return_var = -1;
        $output = array();
        exec(escapeshellcmd($command), $output, $return_var);

        if ($return_var != 0) {
                $error_message = array(
                        "en" => "The password must be at least 8 characters and must not contain your Name or your Surname.",
                        "it" => "La password deve essere lunga almeno 8 caratteri e non deve contenere il tuo Nome o il tuo Cognome."
                );
                //$error_message .= "<br/>";
                //$error_message .= print_r($output, true);
        }
}

if (isset($_SESSION['pw_status'])) unset($_SESSION['pw_status']);
if (isset($_SESSION['pw_message'])) unset($_SESSION['pw_message']);

if ($error_message === false) {
        $_SESSION['pw_status'] = 'ok';
        $_SESSION['pw_message'] = $user_dn;
}
else {
        $_SESSION['pw_status'] = 'error';
        $_SESSION['pw_message'] = $error_message;
}

header("Location: changepw.php");


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
