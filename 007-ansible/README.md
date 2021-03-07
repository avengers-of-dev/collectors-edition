Acknowledgement
===============

I had two starting points:
- https://github.com/adamchainz/mac-ansible
- https://github.com/ayltai/ansible-vscode-mac

Thanks a lot [adamchainz](https://github.com/adamchainz/mac-ansible/commits?author=adamchainz) and [ayltai](https://github.com/ayltai/ansible-vscode-mac/commits?author=ayltai) for sharing your work!


Getting Started
===============

1. Install [homebrew](http://brew.sh/) with the command from the site
2. `brew install pyenv`
3. `pyenv install <latest_python_version>` (Check playbook up to date)
4. Make sure pyenv's python on path (it will be after my shell settings are in place from playbook)
5. `python -m venv venv`
6. `source venv/bin/activate`
5. `pip install ansible` (always the best way to install Ansible)
6. Then `./playbook.yml`

Hints
=====
- this is basically updateing always to latest, not good for production as stuff breaks a lot
- `pyenv rehash` helps when a brew update breaks pyenv
- ansible plugins change a lot and often things break; if you need an old or new part of code use something like: `ansible-galaxy collection install --force git+https://github.com/jaanhio/community.general.git,update-deprecated-homebrew-cask-commands`


Included apps & solutions
=========================
See `playbook.yml`.
