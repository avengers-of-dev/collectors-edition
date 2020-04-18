# graylog lessons learned

It's maybe not the smartest idea to install graylog in the same environment where you are running your apps you want to monitor. In small scale scenarios it might be suitable anyway. Be aware that a lot of data traffic might occur. For example a nearly empty kubernetes cluster can cause 20GB of date for one day and up to 500 to 1000 USD a month costs at your cloud provider.

setup examples:
- kubernetes: (https://github.com/avengers-of-dev/collectors-edition/blob/master/004-kubernetes/21-graylog-kubernetes.yml)
- docker: (https://github.com/avengers-of-dev/collectors-edition/blob/master/005-docker/21-graylog-docker.yml)

# key points of the setup right now

Communication between the graylog components (Graylog, mongodb and elasticsearch) is not yet encrypted and assumed to be very close together with no public data transmission.

Transmission of logdata from endpoints is done with (file beats)[https://www.elastic.co/guide/en/beats/filebeat/] encrypted.

Currently all senders are allowed. It's planned to enhance the examples to use certificates so that only trusted sources can send logs and no "attack" by ddos'ing the graylog server with unauthorised logs.

# setup instructions

After having your instance up and running you need to configure clients / sources to send in logs.

## beats input & tls from let's encrypt

So this part is a bit complicated and only working when you are using a container setup like I described [here](https://github.com/avengers-of-dev/collectors-edition/blob/master/005-docker/12-nginx-docker.yml). In that case you have a certbot container persisting your let's encrypt certifikate on a volume. You need to attach that volume also to your graylog contaienr and configure the used certificate and key file. Let's encrypt doesn't use passwords for keyfiles so you can keep that field empty.

In graylog configure a new beats input.

## macOS client

Could be used for other pc / laptop clients too. See instructions here: [LINK](https://www.elastic.co/guide/en/beats/filebeat/7.6/filebeat-installation.html)

```
brew tap elastic/tap
brew install elastic/tap/filebeat-full
```

Edit the config `/usr/local/etc/filebeat/filebeat.yml` (Mac path, others see: [LINK](https://www.elastic.co/guide/en/beats/filebeat/7.6/directory-layout.html))

Enable the log type input.

```
- type: log

  # Change to true to enable this input configuration.
  enabled: true

  # Paths that should be crawled and fetched. Glob based paths.
  paths:
    - /var/log/*.log
    #- c:\programdata\elasticsearch\logs\*
```

enable the logstash and add the let's encrypt root ca pem file (see: [Let’s Encrypt Authority X3](https://letsencrypt.org/certificates/))

```
#----------------------------- Logstash output --------------------------------
output.logstash:
  # The Logstash hosts
  # hosts: ["192.168.100.30:5044"]
  hosts: ["graylog.your.domain:5044"]

  # Optional SSL. By default is off.
  # List of root certificates for HTTPS server verifications
  ssl.certificate_authorities: ["/Users/jj/Qsync/WorkInProgress/lets-encrypt-x3-cross-signed.pem"]
  
```

Run the beats service on your client.
```
brew services start elastic/tap/filebeat-full
```

To restart the service:
```
brew services restart elastic/tap/filebeat-full
```

Don't forget to allow traffic to the port 5044 here. Graylog will take care to apply the certificate to the tcp connection. You can verify that with:

```
echo | openssl s_client -showcerts -servername graylog.your.domain -connect graylog.your.domain:5044 2>/dev/null | openssl x509 -inform pem -noout -text
```