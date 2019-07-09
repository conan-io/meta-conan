# meta-conan


Introduction
------------

This layer collects recipes required to build and run conan packages on yocto.

Previous poky setup
-------------------

Skip this step if you already have `poky`. 
Clone the `poky` project and checkout the `thud` branch:

```
git clone https://git.yoctoproject.org/git/poky
git checkout thud
```

Requirements
------------

This layer depends on `meta-python`
https://layers.openembedded.org/layerindex/branch/thud/layer/meta-python/

So, going to the URL above, we find the git url: git://git.openembedded.org/meta-openembedded
Clone inside the cloned poky project folder and checkout the `thud` branch.

```
git clone git://git.openembedded.org/meta-openembedded
git checkout thud
```

Now clone this repository also in the `poky` project folder.

```
git clone ssh://git@git.jfrog.info/iot/meta-conan.git
```

Create a new folder `build` where the image will be built.
The following command will create a `conf` directory inside and adjusting the environment to set `bitbake` and other stuff ready.

```
source oe-init-build-env build
```

In the created `build` folder we will find a `conf` directory with a `bblayers.conf` file.
Edit the ``bblayers.conf`` file to add the `meta-openembedded` and `meta-conan` entries. The files should look like this:

```
BBLAYERS ?= " \
  /home/vagrant/secwork/poky/meta \
  /home/vagrant/secwork/poky/meta-poky \
  /home/vagrant/secwork/poky/meta-yocto-bsp \
  /home/vagrant/secwork/poky/meta-openembedded/meta-oe \
  /home/vagrant/secwork/poky/meta-openembedded/meta-python \
  /home/vagrant/meta-conan \
  "
```

Be sure that the meta-openembedded source branch matches the yocto release being used i.e. `thud`.

Let's try to build the `conan` client, go to the build folder and run:

`bitbake python3-conan-native`

Probably you will get some errors, read the output, I needed (in Ubuntu) to install the following packages:

`sudo apt install chrpath diffstat gawk texinfo rpcbind`

It will take some time to build the conan layer and all the dependant layers.

To build base default image:

```
bitbake core-image-minimal
```


Deploying Conan packages to a yocto image
-----------------------------------------

- Develop and upload the Conan packages to a remote Artifactory.
- Use the conan-mosquito (located at `meta-conan/recipes-devtools`) recipe as an example: 


```
conan-mosquitto_1.4.15.bb 
DESCRIPTION = "An open source MQTT broker"
LICENSE = "EPL-1.0"

CONAN_PKG = "mosquitto/1.4.15@bincrafters/stable"
CONAN_REMOTE = "ARTIFACTORY_CONAN_REPOSITORY_URL"
```


To install it add the following lines to the `local.conf` file of your `build` folder:

```
IMAGE_INSTALL_append = " conan-mosquitto"

CONAN_USER = "REPO_USER"
CONAN_PASSWORD = "REPO_PASSWORD"
```

And build it:

```
bitbake conan-mosquitto
```

Build base default image:

```
bitbake core-image-minimal
```

Then try to run:

```
runqemu nographic
```

Finally qemu runs, user `root` and we are able to run mosquitto!


How to deploy to RPI
--------------------

Clone the layer for RPI:

```
git clone git://git.yoctoproject.org/meta-raspberrypi
```


At `conf/local.conf`:

```
# Conan related
IMAGE_INSTALL_append = " conan-mqtt-demo"
CONAN_USER = "conan"
CONAN_PASSWORD = "conanyocto!"

# RPI-3 configs
MACHINE="raspberrypi3-64"
PREFERRED_VERSION_linux-raspberry="4.%"
DISTRO_FEATURES_remove="x11 wayland"
IMAGE_INSTALL_append = " wifi-mycompany rpi-gpio linux-firmware-bcm43430 bluez5 i2c-tools python-smbus bridge-utils hostapd dhcp-server iptables wpa-supplicant openssh"
DISTRO_FEATURES_append = " systemd bluez5 bluetooth wifi"
VIRTUAL-RUNTIME_init_manager = " systemd"
ENABLE_SPI_BUS = "1"
ENABLE_I2C = "1"

```

At `conf/bblayers.conf`

```

BBLAYERS ?= " \
  /home/luism/environment/poky/meta \
  /home/luism/environment/poky/meta-poky \
  /home/luism/environment/poky/meta-yocto-bsp \
  /home/luism/environment/poky/meta-openembedded/meta-oe \
  /home/luism/environment/poky/meta-openembedded/meta-python \
  /home/luism/environment/poky/meta-openembedded/meta-multimedia \
  /home/luism/environment/poky/meta-openembedded/meta-networking \
  /home/luism/environment/poky/meta-conan \
  /home/luism/environment/poky/meta-raspberrypi \  
"
```

Build the image:


```
bitbake core-image-base
```

Use Etcher to burn the SD, the file is at: `{build_folder}/tmp/deploy/images/raspberrypi3-64/core-image-base-raspberrypi3-64.rpi-sdimg`


Log into the RPI and configure the wifi:

```
vi /etc/wpa_supplicant.conf
```

Change to content to following

```
ctrl_interface=/var/run/wpa_supplicant
ctrl_interface_group=0
update_config=1
network={
    ssid=”<SSID_NAME>”
    psk=”<PASSWORD>”
    proto=RSN
    key_mgmt=WPA-PSK
    pairwise=CCMP
    auth_alg=OPEN
}
```

Restart Rpi3 with `reboot`
Log in to Raspberry Pi 3 and configure Wi-Fi

```
ifup wlan0
```
