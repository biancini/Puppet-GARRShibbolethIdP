/*
 * it.garr.ldap.jaas.LdapLoginModule
 *
 * Copyright (C) 2013-2013 Consortium GARR.
 * All rights reserved.
 */
package org.ldaptive.jaas;

import java.util.Arrays;
import java.util.Map;

import javax.security.auth.Subject;
import javax.security.auth.callback.CallbackHandler;
import javax.security.auth.callback.NameCallback;
import javax.security.auth.callback.PasswordCallback;
import javax.security.auth.login.LoginException;

import org.ldaptive.Credential;
import org.ldaptive.LdapEntry;
import org.ldaptive.LdapException;
import org.ldaptive.auth.AccountState;
import org.ldaptive.auth.AuthenticationRequest;
import org.ldaptive.auth.AuthenticationResponse;
import org.ldaptive.auth.Authenticator;
import org.ldaptive.auth.ext.PasswordPolicyAccountState;
import org.ldaptive.control.PasswordPolicyControl;


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
public class GarrLdapLoginModule extends AbstractLoginModule {
	
	/** User attribute to add to role data. */
	private String[] userRoleAttribute = new String[0];

	/** Factory for creating authenticators with JAAS options. */
	private AuthenticatorFactory authenticatorFactory;

	/** Authenticator to use against the LDAP. */
	private Authenticator auth;

	/** Authentication request to use for authentication. */
	private AuthenticationRequest authRequest;


	/** {@inheritDoc} */
	@Override
	public void initialize(
			final Subject subject,	
			final CallbackHandler callbackHandler,
			final Map<String, ?> sharedState,
			final Map<String, ?> options) {
		setLdapPrincipal = true;
		setLdapCredential = true;
		
		super.initialize(subject, callbackHandler, sharedState, options);

		for (String key : options.keySet()) {
			final String value = (String) options.get(key);
			if ("userRoleAttribute".equalsIgnoreCase(key)) {
				if ("*".equals(value)) {
					userRoleAttribute = null;
				} else {
					userRoleAttribute = value.split(",");
				}
			} else if ("authenticatorFactory".equalsIgnoreCase(key)) {
				try {
					authenticatorFactory =	(AuthenticatorFactory) Class.forName(value).newInstance();
				} catch (ClassNotFoundException e) {
					throw new IllegalArgumentException(e);
				} catch (InstantiationException e) {
					throw new IllegalArgumentException(e);
				} catch (IllegalAccessException e) {
					throw new IllegalArgumentException(e);
				}
			}
		}

		if (authenticatorFactory == null) {
			authenticatorFactory = new PropertiesAuthenticatorFactory();
		}

	    logger.trace("authenticatorFactory = {}, userRoleAttribute = {}",
	    		authenticatorFactory,
	    		Arrays.toString(userRoleAttribute));

	    auth = authenticatorFactory.createAuthenticator(options);
	    logger.debug("Retrieved authenticator from factory: {}", auth);

	    authRequest = authenticatorFactory.createAuthenticationRequest(options);
	    authRequest.setReturnAttributes(userRoleAttribute);
	    logger.debug("Retrieved authentication request from factory: {}", authRequest);
	}


	/** {@inheritDoc} */
	public boolean login() throws LoginException {
		try {
			final NameCallback nameCb = new NameCallback("Enter user: ");
			final PasswordCallback passCb = new PasswordCallback("Enter user password: ", false);
			getCredentials(nameCb, passCb, false);
			authRequest.setUser(nameCb.getName());
			authRequest.setCredential(new Credential(passCb.getPassword()));

			String loginMessage = null;
			AuthenticationResponse response = auth.authenticate(authRequest);
			LdapEntry entry = null;
			if (response.getResult()) {
				entry = response.getLdapEntry();
				if (entry != null) {
					roles.addAll(LdapRole.toRoles(entry));
					if (defaultRole != null && !defaultRole.isEmpty()) {
						roles.addAll(defaultRole);
					}
				}
				loginSuccess = true;
				// Code added/modified by GARR to verify the CHANGE_AFTER_RESET error.
				AccountState accountState = response.getAccountState();
				if (accountState != null && accountState instanceof PasswordPolicyAccountState) {
					PasswordPolicyControl.Error ppControlError = ((PasswordPolicyAccountState) accountState).getPasswordPolicyError();
					if (ppControlError == PasswordPolicyControl.Error.CHANGE_AFTER_RESET) {
						logger.debug("CHANGE_AFTER_RESET error found, denying access.");
						loginMessage = "CHANGE_AFTER_RESET flag with TRUE value";
						loginSuccess = false;
					}
				}
				// End of code added/modified by GARR
			} else {
				if (tryFirstPass) {
					getCredentials(nameCb, passCb, true);
					response = auth.authenticate(authRequest);
					if (response.getResult()) {
						entry = response.getLdapEntry();
						if (entry != null) {
							roles.addAll(LdapRole.toRoles(entry));
						}
						if (defaultRole != null && !defaultRole.isEmpty()) {
							roles.addAll(defaultRole);
						}
						loginSuccess = true;
						// Code added/modified by GARR to verify the CHANGE_AFTER_RESET error.
						AccountState accountState = response.getAccountState();
						if (accountState != null && accountState instanceof PasswordPolicyAccountState) {
							PasswordPolicyControl.Error ppControlError = ((PasswordPolicyAccountState) accountState).getPasswordPolicyError();
							if (ppControlError == PasswordPolicyControl.Error.CHANGE_AFTER_RESET) {
								logger.debug("CHANGE_AFTER_RESET error found, denying access.");
								loginMessage = "CHANGE_AFTER_RESET flag with TRUE value";
								loginSuccess = false;
							}
						}
						// End of code added/modified by GARR
					} else {
						loginSuccess = false;
					}
				} else {
					loginSuccess = false;
				}
			}

			if (!loginSuccess) {
				String message = "Authentication failed: " + response;
				if (loginMessage != null) message += " (" + loginMessage + ")";
				logger.debug(message);
				throw new LoginException(message);
			} else {
				if (setLdapPrincipal) {
					final LdapPrincipal lp = new LdapPrincipal(nameCb.getName(), entry);
					principals.add(lp);
				}

				final String loginDn = auth.resolveDn(nameCb.getName());
				if (loginDn != null && setLdapDnPrincipal) {
					final LdapDnPrincipal lp = new LdapDnPrincipal(loginDn, entry);
					principals.add(lp);
				}
				if (setLdapCredential) {
					credentials.add(new LdapCredential(passCb.getPassword()));
				}
				storeCredentials(nameCb, passCb, loginDn);
			}
		} catch (LdapException e) {
			logger.debug("Error occured attempting authentication", e);
			loginSuccess = false;
			throw new LoginException(e != null ? e.getMessage() : "Authentication Error");
		}
		return true;
	}

}