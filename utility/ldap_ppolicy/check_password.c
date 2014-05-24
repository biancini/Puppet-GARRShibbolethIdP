#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "portable.h"
#include "slap.h"

int init_module() {
    return 0;
}

int check_password(char *pPasswd, char **ppErrStr, Entry *pEntry) {
/*    char pwqr = 0;
    char retmsg[255];
    char *message;

    int has_digit = 0;
    int has_alpha = 0;
    char digit[11];
    strcpy(digit, "0123456789");
    char alpha[60];
    strcpy(alpha, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ");
    char valid[20];
    strcpy(valid, "/%$£^&@()*+-=;:,_^");

    char bad_char = 0;
    int i = 0;
    int j = 0;

    for (i = 0; i < strlen(pPasswd); i++) {
        int found = 0;
        char this_char = pPasswd[i];

        //Search valid digit into password
        for (j = 0; j < strlen(digit); j++) {
            if (this_char == digit[j]) {
                has_digit = 1;
                found = 1;
            }
        }
        //Search valid character into password
        for (j = 0; j < strlen(alpha); j++) {
            if (this_char == alpha[j]) {
                has_alpha = 1;
                found = 1;
            }
        }

        //Search valid symbol into password
        for (j = 0; j < strlen(valid); j++) {
            if (this_char == valid[j]) {
                found = 1;
            }
            else {
                bad_char = this_char;
            }
        }

        //The value of flag 'found' will be 0 if the password doesn't contain any
        //digit or alpha or valid character, but only bad character and the first of them
        //is in the variable bad_char.
        if (0 == found) {
            pwqr = 1;
            char inv_char_msg[80];
            sprintf(inv_char_msg, "Invalid char in password: %c.", bad_char);

            strcpy(retmsg, inv_char_msg);
        }
    }

    //Check to control if the password has at least one digit
    if (0 == has_digit) {
        pwqr = 1;
        strcpy(retmsg, "Password must contain at least one digit.");
    }

    //Check to control if the password has at least one valid character
    if (0 == has_alpha) {
        pwqr = 1;
        strcpy(retmsg, "Password must contain at least one letter.");
    }
*/
    char *message;
    char retmsg[255];

    if (pEntry != NULL && pEntry->e_attrs != NULL) {
        Attribute *attr = NULL;
        for (attr = pEntry->e_attrs; attr != NULL; attr = attr->a_next) {
                if (attr->a_desc == NULL) continue;
                if (attr->a_vals == NULL) continue;

                char *attrname = attr->a_desc->ad_cname.bv_val;
                char *attrvalue = attr->a_vals[0].bv_val;

                if (strncasecmp("givenName", attrname, 9) == 0 || strncasecmp("sn", attrname, 2) == 0) {
                        //Check if the name or the surname are into the password
                        if (strcasestr(pPasswd, attrvalue) != 0) {
                                pwqr = 1;
                                strcpy(retmsg , "Name or Surname must not be into your password");
                        }
                }
        }
    }

    /* Allocate  */
    message = (char *)malloc(strlen(retmsg) + 1);
    /* Copy the contents of the string. */
    message = strdup(retmsg);

    *ppErrStr = message;
    return pwqr;
}
