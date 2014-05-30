#!/usr/bin/env python

import sys
import os, datetime
import string
from random import randint, choice
from urlparse import urlparse

try:
  from jinja2 import Template
except ImportError:
  print >> sys.stderr, "To execute this script you need to install Jinja2 templating engine."
  print >> sys.stderr, "On ubuntu execute:"
  print >> sys.stderr, "  sudo apt-get install python-jinja2"
  sys.exit(1)

def request(prompt_str="Specify a text", example="random text", allow_empty=False, example_as_default=False):
  """This function request something to an user and return the answer.
  
  Keyword arguments:
    prompt_str -- String containing the information request for the user.
    example -- String containing an example of information that the user must insert.
    allow_empty -- Boolean who tells if the answer could be empty.
    example_as_default -- Boolean who tells if the example will be used as default value for an empty answer.

  Output: Return the response provided by the user.

  """
  while True:
    prompt = '%s [eg: %s]: ' % (prompt_str, example)
    ans = raw_input(prompt)
    if ans == '' and example_as_default: return example 
    if ans != '' or allow_empty: return ans 

def confirm(prompt_str="Confirm", allow_empty=False, default=False):
  """This function request a confirm to an answer and return True or False

  Keyword arguments:
    prompt_str -- String containing the information that the user have to confirm.
    allow_empty -- Boolean who tells if the response could be empty.
    defaul -- Boolean who tells if a default response is available.

  Output: Return True if the user confirm the request, False otherwise.   

  """
  fmt = (prompt_str, 'y', 'n') if default else (prompt_str, 'n', 'y')

  if allow_empty:
    prompt = '%s [%s]|%s: ' % fmt
  else:
    prompt = '%s %s|%s: ' % fmt
 
  while True:
    ans = raw_input(prompt).lower()
 
    if ans == '' and allow_empty:
      return default
    elif ans == 'y':
      return True
    elif ans == 'n':
      return False
    else:
      print 'Please enter y or n.'

def reg_instant():
   """This function returns the instant when the entity was registered with the authority.
      
   Output: Time value expressed in the UTC timezone using the 'Z' timezone identifier.

   """

   instant = datetime.datetime.now()
   nowFormatted = datetime.datetime(instant.year, instant.month, instant.day, instant.hour, instant.minute, instant.second)

   return nowFormatted.isoformat()+'Z'

def generate_random_pass():
  characters = string.ascii_letters + string.digits
  password = "".join(choice(characters) for x in range(randint(16, 16)))
  return password

idpDomainName = 'example.com'

# Dictionary containing values to be used to render template
sitepp_vals = {}

print "Step 1/2: in the following the information present in the \"Request form\" well be asked:"

entityId = request("Insert the IdP entityID", "https://idp.puppetclient.[irccs|izs].garr.it/idp/shibboleth")

try:
  o = urlparse(entityId)
  if not o.hostname: raise Exception("no hostname")
  sitepp_vals['idpfqdn'] = o.hostname
except Exception:
  sitepp_vals['idpfqdn'] = request("Insert the fully qualified domain name of the IdP host", "idp.%s" % idpDomainName)

if '.' in sitepp_vals['idpfqdn']: 
  sitepp_vals['hostname'] = sitepp_vals['idpfqdn'].partition('.')[0]
  idpDomainName = sitepp_vals['idpfqdn'].partition('.')[-1]

i = 0
for dc in idpDomainName.split('.'):
  if i==0:
    basedn = "dc="+dc
  else:
    basedn += "," + "dc="+dc
  i += 1

# Retrieve the baseDN for LDAP from the web site of Institution
sitepp_vals['domain_name'] = request("Specify the organization internet domain", idpDomainName, example_as_default=(idpDomainName != 'example.com'))

sitepp_vals['mdui_langs'] = request("Insert the languages to be used for MDUI information separated by space", "en it", example_as_default=True)
sitepp_vals['mdui_langs'] = sitepp_vals['mdui_langs'].split(' ')

for curlang in sitepp_vals['mdui_langs']:
  print ""
  print "Insert all values for MDUI information relative to language %s" % curlang
  sitepp_vals['orgDisplayName_%s' % curlang] = request("Insert the organization name for language %s" % curlang, "[IRCCS | IZS] Test IdP in the Cloud Project", example_as_default=False)

  sitepp_vals['communityDesc_%s' % curlang] = "Identity Provider of %s" % sitepp_vals['orgDisplayName_%s' % curlang]

  sitepp_vals['orgUrl_%s' % curlang] = request("Insert the URL of the web site of the organisation (md:OrganizationURL) for language %s" % curlang, "http://www.%s" % idpDomainName, example_as_default=True)

  sitepp_vals['privacyPage_%s' % curlang] = request("Insert the Privacy Statement URL of the organisation for language %s" % curlang, "https://%s/idp/privacy.html" % sitepp_vals['idpfqdn'], example_as_default=True)

  sitepp_vals['idpInfoUrl_%s' % curlang] = request("Insert the Information URL of the organisation for language %s" % curlang, "https://%s/idp/info.html" % sitepp_vals['idpfqdn'], example_as_default=True)

  sitepp_vals['nameOrg_%s' % curlang] = sitepp_vals['orgDisplayName_%s' % curlang]

  sitepp_vals['url_LogoOrg_32x32_%s' % curlang] = request("Insert the URL of the image's logo sized 32x32 pixel for language %s" % curlang, "https://%s/idp/images/institutionLogo-32x32_%s.png" % (sitepp_vals['idpfqdn'], curlang), example_as_default=True)

  sitepp_vals['url_LogoOrg_160x120_%s' % curlang] = request("Insert the URL of the image's logo sized 160x120 pixel for language %s" % curlang, "https://%s/idp/images/institutionLogo-160x120_%s.png" % (sitepp_vals['idpfqdn'], curlang), example_as_default=True)

print ""
sitepp_vals['technicalEmail'] = request("Insert a valid email address to be used for technical inquiries from IDEM federation", "idpcloud-service@garr.it")
#sitepp_vals['technicalIDPadminGivenName'] = request("Insert Name IdP's Admin (leave empty if unknown)", "Technical", allow_empty=True)
#sitepp_vals['technicalIDPadminSurName'] = request("Insert Surname IdP's Admin", "Support", example_as_default=True)
#sitepp_vals['technicalIDPadminTelephone'] = request("Insert Telephone IdP's Admin", "+39 012 345 678 9", example_as_default=True)

print ""
print "Step 2/2: in the following some addtional information will be asket to configure the technical aspects of the IdP:"

idp_instant = reg_instant()
password = generate_random_pass()

#sitepp_vals['registrationInstant'] = request("Insert the instant when the entity was registered with the Authority", idp_instant, example_as_default=True)
sitepp_vals['registrationInstant'] = idp_instant

sitepp_vals['configure_admin'] = str(confirm("Install Tomcat admin interface?", allow_empty=True)).lower()
if sitepp_vals['configure_admin'] == 'true':
  sitepp_vals['tomcat_admin_password'] = request("Insert the password for user admin on Tomcat", "adminpassword")
  sitepp_vals['tomcat_manager_password'] = request("Insert the password for user manager on Tomcat", "managerpassword")

#sitepp_vals['shibbolethversion'] = "'%s'" % request("Specify the IdP version you would like to install", "2.4.0", example_as_default=True)
sitepp_vals['shibbolethversion'] = "undef"

sitepp_vals['install_uapprove'] = str(confirm("Install uApprove on the IdP?", allow_empty=True, default=True)).lower()

sitepp_vals['mailto'] = sitepp_vals['technicalEmail']

#sitepp_vals['keystorepassword'] = request("Specify the password for the keystore to be used inside Tomcat", password, example_as_default=True)
#sitepp_vals['rootpw'] = request("Specify the password for the IdP technical user", sitepp_vals['keystorepassword'], example_as_default=True)
sitepp_vals['keystorepassword'] = sitepp_vals['rootpw'] = sitepp_vals['rootldappw'] = password

sitepp_vals['install_ldap'] = str(confirm("Install LDAP server on the IdP?", allow_empty=True, default=True)).lower()

#sitepp_vals['domain_name'] = request("Specify the LDAP domain name", idpDomainName, example_as_default=True)
sitepp_vals['domain_name'] = idpDomainName
sitepp_vals['basedn'] = request("Specify the LDAP base DN", basedn, example_as_default=True)
sitepp_vals['rootdn'] = request("Specify the root user DN", "cn=admin", example_as_default=True)
#sitepp_vals['rootldappw'] = request("Specify the password for the LDAP root user", sitepp_vals['rootpw'], example_as_default=True)
##sitepp_vals['rootldappw'] = password

if sitepp_vals['install_ldap'] == 'true':
  sitepp_vals['ldap_host'] = "undef"
  sitepp_vals['ldap_use_ssl'] = "undef"
  sitepp_vals['ldap_use_tls'] = "undef"
else:
  sitepp_vals['ldap_host'] = "'%s'" % request("Specify the LDAP host to be contacted by the IdP", "ldapserver."+sitepp_vals['idpDomainName']+":389",example_as_default=True)
  sitepp_vals['ldap_use_ssl'] = str(confirm("Use SSL to connect to LDAP host?", allow_empty=True, default=True)).lower()
  sitepp_vals['ldap_use_tls'] = str(confirm("Use TLS to connect to LDAP host?", allow_empty=True)).lower()

sitepp_vals['logserver'] = request("Specify the central log server (if present, leave empty instead)", "splunk.openstacklocal", allow_empty=True)
sitepp_vals['collectdserver'] = request("Specify the central CollectD server (if present, leave empty instead)", "collectd.openstacklocal", allow_empty=True)
sitepp_vals['nagiosserver'] = request("Specify the central Nagios server (if present, leave empty instead)", "nagios.openstacklocal", allow_empty=True)
sitepp_vals['sambadomain'] = request("Specify the samba domain for the IdP server", "IDP-IN-THE-CLOUD", example_as_default=True)

sitepp_vals['test_federation'] = request("Use IDEM Test Federation or not?", "true", example_as_default=True)
#sitepp_vals['custom_styles'] = request("Use the IdP in the Cloud custom files for IdP Login Page (true) or leave the originals (false)?", "true", example_as_default=True)
sitepp_vals['custom_styles'] = "true"
#sitepp_vals['first_install'] = request("This is a new IdP or not?", "true", example_as_default=True)
sitepp_vals['first_install'] = "true"

#sitepp_vals['enable_network'] = request("Insert the network netmask where SSH the other management services will be accessible", "10.0.0.0/24", allow_empty=True)

print ""
print "Generating site.pp...."

sitepp = open('site.pp.template', 'r').read()
sitepp = Template(sitepp).render(vals=sitepp_vals)

config_basedir = "/etc/puppet"
if os.path.exists("/etc/puppet/environments"):
  config_basedir += "/environments/test"

f1 = open("%s/manifests/nodes/%s.pp" % (config_basedir, sitepp_vals['idpfqdn']), "w")
f1.write(sitepp)
f1.close()

modify_sitepp = True
for line in open("%s/manifests/site.pp" % config_basedir, "r").readlines():
  if line == "import 'nodes/%s.pp'\n" % sitepp_vals['idpfqdn']:
    modify_sitepp = False

if modify_sitepp:
  f2 = open("%s/manifests/site.pp" % config_basedir, "a")
  f2.write("import 'nodes/%s.pp'\n" % sitepp_vals['idpfqdn'])
  f2.close()

print "Done."
#os.system("service puppetmaster restart")
