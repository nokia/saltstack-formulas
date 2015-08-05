
{% from 'system/install.sls' import install_tarball with context %}

{{ install_tarball('scala', True) }}