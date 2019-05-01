# WP Starter 3.0 - VVV site template

under development.

1) [Install VVV](https://varyingvagrantvagrants.org/docs/en-US/installation/)

2) [Optional] To be able to clone private repositories:
	- [Add a new SSH key](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/) to your GitHub account.
	- Set up SSH forwarding by [adding your SSH key to the ssh-agent](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/#adding-your-ssh-key-to-the-ssh-agent)

3) In the local VVV folder, create the following vvv-custom.yml file:

	```yml
	sites:
	  wpstarter:
	    repo: https://github.com/soderlind/wpstarter-vvv
	    nginx_upstream: php73
	    hosts:
	      - wpstarter.test
	    custom:
	      wp_type: subdirectory
	      wp_version: latest
	      acf_pro_key: acf_pro_license_key

	vm_config:
	  memory: 2048
	  cores: 2

	utilities:
	  core:
	    - php73

	utility-sources:
	  core: https://github.com/Varying-Vagrant-Vagrants/vvv-utilities.git
	```

4) In the local VVV folder run `vagrant up`, or `vagrant reload --provision` if vagrant is already running.
