# Meta Conan: A Yocto layer for Conan client

[![Build Status](https://ci.conan.io/job/meta-conan/job/master/badge/icon)](https://ci.conan.io/job/meta-conan/job/master/)

Introduction
------------

This layer collects recipes required to use the Conan Package Manager client in the Yocto builds.
With this layer you can write simple Bitbake recipes to retrieve and deploy Conan packages from an Artifactory repository.

*conan-mosquitto_2.0.15.bb*
```
    inherit conan

    DESCRIPTION = "An open source MQTT broker"
    LICENSE = "EPL-1.0"

    CONAN_PKG = "mosquitto/2.0.15"
````

Read how to use this layer in the Conan documentation: https://docs.conan.io/en/latest/integrations/cross_platform/yocto.html

**WARNING**: The current documentation is outdated and should not work properly

Requirements
------------

This layer depends on the `meta-python` layer: https://layers.openembedded.org/layerindex/branch/thud/layer/meta-python/


License
-------
[MIT](LICENSE.md)
