# what is in it?

few words upfront: I know many people are using bitnamis kubeapps and helm charts. But I always like to know whats going on in my cluster and prefer to create my own stack yaml files. Nothing is perfect, still much to improve but better in my eyes than running random stuff with one click someone else created.

the provided yamls are tested and working on msft azure and make use of azure key vault and azure file as storage solution.

all services which are exposing a web frontend are using traefik. If you don't want to use that, you have to find a solution on your own.

one word also for logging: I have tested graylog because I really like it and it is working quite nice also in a kubernetes environment. But be aware that a cluster is really noisy! An nearly empty cluster like the one we have created here creates up to 20GB of data a day which means around 500 to 1'000 USD of costs at your cloud provider a month (considering that not only data at rest is payed but also inserting and reading data).


| # | app / tech  | description  |
|---|---|---|
| 00 | [basic-resources](00-basic-resources.yml) | some basic resources you will need like access to file storage and key vault|
| 10 | [portainer-kubernetes](10-portainer-kubernetes.yml) | portainer as a graphical interface |
| 00 | [traefic-kubernetes](11-traefic-kubernetes.yml) | traefik reverse prox incl. let's encrypt |
| 00 | [owntracks-kubernetes](20-owntracks-mosquitto-kubernetes.yml) | test of running a own tracks backend |
| 00 | [graylog-kubernetes](21-graylog-kubernetes.yml) | consolidating all logs from a cluster. Take care of the amount of data and your cloud costs! |
| 00 | [dummy-test-app](99-dummy-test-app.yml) | a dummy test app displaying some infos |