#!/usr/bin/python

import smtplib
import email
import email.encoders
import email.mime.text
import email.mime.base
import base64
import sys
import re

hostname = sys.argv[1]
#path = '/root/certificates/'
path = '/tmp/'
filename = '%s-csr-request.csr' % hostname
senderName = 'IdP in the cloud service <idpcloud-service@garr.it>'
receiverName = 'GARR Certificate Authority <system.support@garr.it>'

sender = re.search('.*<(.*)>', senderName).group(1)
receiver = re.search('.*<(.*)>', receiverName).group(1)

html = """
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<body style="font-size:12px;font-family:Verdana">
<p>Certificate signature request for IdP in the cloud: %s.</p>
</body></html>
""" % (hostname)
emailMsg = email.MIMEMultipart.MIMEMultipart('alternative')
emailMsg['Subject'] = 'Certificate request for IdP in the cloud'
emailMsg['From'] = senderName
emailMsg['To'] = receiverName
#emailMsg['Cc'] =
emailMsg.attach(email.mime.text.MIMEText(html, 'html'))

fileMsg = email.mime.base.MIMEBase('text', 'plain; charset=UTF-8; name="%s"' % filename)
fileMsg.set_payload(file(path + filename).read())
email.encoders.encode_base64(fileMsg)
fileMsg.add_header('Content-Disposition', 'attachment; filename="%s"' % filename)
emailMsg.attach(fileMsg)

try:
  smtpObj = smtplib.SMTP('mail.openstacklocal')
  smtpObj.sendmail(sender, receiver, emailMsg.as_string())
  smtpObj.quit()
  print "Successfully sent email"
  exit(0)
except Exception as e:
  print "Error: unable to send email"
  print e
  exit(1)

