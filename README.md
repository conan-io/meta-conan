# meta-conan

Introduction
------------

This layer collects recipes required to use the Conan Package Manager client in the Yocto builds.
With this layer you can write simple Bitbake recipes to retrieve and deploy Conan packages from an Artifactory repository.

*conan-mosquitto_1.4.15.bb*
```
    inherit conan

    DESCRIPTION = "An open source MQTT broker"
    LICENSE = "EPL-1.0"

    CONAN_PKG = "mosquitto/1.4.15@bincrafters/stable"
````

Read how to use this layer in the Conan documentation: https://docs.conan.io/en/latest/integrations/cross_platform/yocto.html

Requirements
------------

This layer depends on the `meta-python` layer: https://layers.openembedded.org/layerindex/branch/thud/layer/meta-python/

ASDASDASDASDASD