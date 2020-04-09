# nginx lessons learned
This subfolder contains everything about nginx and a bit nginx plus stuff.

We are using let's encrypt. This is important as it impacts how we deal with secrets and how the default servers look like.

## how to use it

I tried to make all as clean as possible to allow out of the box usage. Go to the `/etc/nginx/include/` and set your instance specific variables and then you should be good to go.

## structure of the config

We generally recommend to split the nginx configuration to have a better overview and avoid redundand information accross config files.

**/etc/nginx/nginx.conf**
The main nginx config file contains all basic stuff like ssl & proxy settings which don't change no matter which server / location is requested.

**/etc/nginx/include/*.include**
We are using some include files to avoid the need of repeating the same settings in location blocks of specific virtual hosts. It's possible to change things in one place and all virtual hosts apply the change. No need to change the same value in alle files. It's possible to overwrite values in a specific location block if needed.

**/etc/nginx/conf.d/default.conf**
This file contains default virtual servers which for example take care of redirecting http to https, let's encrypt or when in use the nginx plus dashboard.

**/etc/nginx/conf.d/example.blog.conf**
The remaining site specific settings are not tto much as all default settings are already done. We use to create one config file per page and keep them as well as all other stuff in a private repository to track changes and redeploy quickly if needed.
