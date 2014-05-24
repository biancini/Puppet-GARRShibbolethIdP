#!/usr/bin/python

import os, sys, dns.resolver
from novaclient.v1_1 import client

#USER = os.environ['OS_USERNAME']
#PASS = os.environ['OS_PASSWORD']
#TENANT = os.environ['OS_TENANT_NAME']
#AUTH_URL = os.environ['OS_AUTH_URL']
USER="admin"
PASS=""
TENANT="idp-on-demand"
AUTH_URL="http://192.168.0.115:5000/v2.0/"

NSUPDATE_CMD="/usr/bin/nsupdate"
KEYFILE="Kopenstacklocal.+157+08895.key"
DNS_SERVER="192.168.223.4"
DEFAULT_ZONE="openstacklocal"

class nsupdate:
    def __init__(self, config):
        self.config = config
        self.command = "%s -v -k %s" % (self.config['nscmd'], self.config['keyfile'])
        self.batch = []
        self.batch.append("server %s" % self.config['server'])

    def domainExists(self, domain):
                parts = domain.split('.')
                zone = '.'.join(parts[1:])
                if not zone:
                        zone=DEFAULT_ZONE
                        domain="%s.%s" % (domain,zone)

        try:
            answer = dns.resolver.query(domain, 'a')
        except dns.resolver.NXDOMAIN:
            return 0
        else:
            return 1

    def addDomain(self, domain, *args):
        parts = domain.split('.')
        name=parts[0]
                if name == "dns" or name == "dns2":
                        print "Skip... Cannot change DNS IP ADDRESS"
                else:
            zone = '.'.join(parts[1:])
            if not zone:
                zone=DEFAULT_ZONE
                domain="%s.%s" % (domain,zone)
            #self.batch.append("zone %s" % zone)
            self.batch.append("update add %s %s IN %s" % (domain, self.config['timeout'], args[0]))
        

    def delDomain(self, domain, *args):
        parts = domain.split('.')
        name=parts[0]
        if name == "dns" or name == "dns2":
            print "Skip... Cannot change DNS IP ADDRESS"
        else:
            zone = '.'.join(parts[1:])
            if not zone:
                zone=DEFAULT_ZONE
                domain="%s.%s" % (domain,zone)
            #self.batch.append("zone %s" % zone)
            self.batch.append("update delete %s %s IN %s" % (domain, self.config['timeout'], args[0]))

    def stampa(self):
        for i in self.batch:
            print '%s' % i
    
    def commit(self):
        self.batch.append("send")
        opipe = os.popen(self.command, 'w')
        for b in self.batch:
            print b
            opipe.write("%s\n" % b)
        opipe.close()

if __name__ == "__main__":
    config = {} 
    config['nscmd'] =  NSUPDATE_CMD
    config['server'] = DNS_SERVER
    config['keyfile'] = KEYFILE
    config['timeout'] = 36000

    serverlist = []

    nt = client.Client(USER, PASS, TENANT, AUTH_URL, service_type="compute")
    servers = nt.servers.list()

    for server in servers:
            #print server.__dict__
            curserver = {}
            curserver['name'] = server.name
            curserver['floating_ip'] = None
            curserver['fixed_ip'] = None
    
            for key,values in server.addresses.items():
                    for address in values:
                            if address['OS-EXT-IPS:type'] == 'fixed':
                                    curserver['fixed_ip'] = address['addr']
                            elif address['OS-EXT-IPS:type'] == 'floating':
                                    curserver['floating_ip'] = address['addr']
    
            serverlist.append(curserver)

    #Inizializzo il gestore del DNS
    NS = nsupdate(config)
    
    for server in serverlist:
            #print "%s\t%s\t%s" % (server['name'], server['fixed_ip'], server['floating_ip'])
        if NS.domainExists(server['name']):
            print "\nESISTE -> Prima lo rimuovo\n"
            NS.delDomain(server['name'], 'A')

        print "\nNONESISTE-> Lo aggiungo \n"
        NS.addDomain(server['name'], 'A %s' % server['fixed_ip'])

    #NS.stampa()
    #INVIO L'UPDATE AL SERVER
    NS.commit()
