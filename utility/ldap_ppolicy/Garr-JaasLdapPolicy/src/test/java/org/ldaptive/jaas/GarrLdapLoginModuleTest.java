/*
 * it.garr.ldap.jaas.LdapLoginModule
 *
 * Copyright (C) 2013-2013 Consortium GARR.
 * All rights reserved.
 */
package org.ldaptive.jaas;

import java.io.IOException;
import java.net.URL;
import java.security.Principal;
import java.util.Set;

import javax.security.auth.callback.Callback;
import javax.security.auth.callback.CallbackHandler;
import javax.security.auth.callback.NameCallback;
import javax.security.auth.callback.PasswordCallback;
import javax.security.auth.callback.UnsupportedCallbackException;
import javax.security.auth.login.Configuration;
import javax.security.auth.login.LoginContext;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import com.sun.security.auth.login.ConfigFile;


/**
 * Provides a JAAS authentication hook for LDAP authentication
 * and manages the LDAP policies.
 * This module in particular denies access if the LDAP answers with
 * a CHANGE_AFTER_RESET error.
 *
 * @author   Andrea Biancini <andrea.biancini@garr.it>
 * @author   Marco Malavolti <marco.malavolti@garr.it>
 * @version  0.9 September, 25 2013
 */
@RunWith(JUnit4.class)
@SuppressWarnings("restriction")
public class GarrLdapLoginModuleTest {
	
	/**
	 * This provides command line access to this JAAS module.
	 *
	 * @param  args  command line arguments
	 *
	 * @throws  Exception  if an error occurs
	 */
	@Test
	public void testLogin() throws Exception {
		// given
		String name = "ldaptive";
		final String username = "andrea";
		final String password = "ciaoandrea";
		
		CallbackHandler callbackHandler = new CallbackHandler() {
			public void handle(Callback[] callbacks) throws IOException, UnsupportedCallbackException {
				for (int i = 0; i < callbacks.length; i++) {
					if (callbacks[i] instanceof NameCallback) {
			            NameCallback ncb = (NameCallback) callbacks[i];
			            ncb.setName(username);
			        } else if (callbacks[i] instanceof PasswordCallback) {
						PasswordCallback pc = (PasswordCallback) callbacks[i];
						pc.setPassword(password.toCharArray());
					}
					else {
						throw new UnsupportedCallbackException(callbacks[i], "Unrecognized Callback");
					}
				}
			}
		};

		URL url = getClass().getClassLoader().getResource("jaas.conf");
		Configuration config = new ConfigFile(url.toURI());
		final LoginContext lc = new LoginContext(name, null, callbackHandler, config);
		
		// when
		lc.login();
		
		boolean usernameFound = false;
		final Set<Principal> principals = lc.getSubject().getPrincipals();
		for (Principal principal : principals) {
			if (principal.getName().equals(username)) {
				usernameFound = true;
			}
		}
		
		//then
		assert(usernameFound);
		lc.logout();
	}

}
