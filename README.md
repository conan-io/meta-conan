# Meta Conan: A Yocto layer for Conan client

[![Yocto Layer Validation](https://github.com/conan-io/meta-conan/actions/workflows/yocto-validation.yml/badge.svg)](https://github.com/conan-io/meta-conan/actions/workflows/yocto-validation.yml)


## Introduction

This layer collects recipes required to use the Conan Package Manager client in the Yocto builds.
With this layer you can write simple Bitbake recipes to retrieve and deploy Conan packages from an Artifactory repository.

*conan-mosquitto_2.0.18.bb*
```
    inherit conan

    DESCRIPTION = "An open source MQTT broker"
    LICENSE = "EPL-1.0"

    CONAN_PKG = "mosquitto/2.0.18"
````

## Conan 2.x support

This current branch is **only** working with Conan 2.x. If you are using Conan 1.x, please use other branches without the `conan2` prefix.

## Documentation

Read how to use this layer in the Conan documentation: https://docs.conan.io/en/latest/integrations/cross_platform/yocto.html

**WARNING**: The current documentation is outdated and should not work properly

## Requirements

This layer depends on the `meta-python` layer: https://layers.openembedded.org/layerindex/branch/thud/layer/meta-python/

## Contributing

Please submit any patches against the `meta-conan` layer by using the GitHub pull-request feature. Use the default branch (currently `conan2/scarthgap`) as base branch.

## License

[MIT](https://github.com/conan-io/conan/blob/develop/LICENSE.md)
