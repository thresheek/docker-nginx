# Adding third-party modules to nginx official image

It's currently possible to extend a mainline Debian-based image with
third-party modules either from your own instuctions following a simple
filesystem layout/syntax using build_module.sh helper script, or failing back
to package sources from https://hg.nginx.org/pkg-oss.

## Usage

```
$ docker build --build-arg ENABLED_MODULES="ndk lua" -t my-nginx-with-lua .
```
This command will attempt to build an image called `my-nginx-with-lua` based on
official nginx docker hub image with two modules: `ndk` and `lua`.

The build script will look for module build definition files on filesystem
directory under the same name as the module (and resulting package) and if
those are not found will try to look up requested modules in the pkg-oss
repository.

For well-known modules we maintain a set of build sources packages over at
`pkg-oss`, so it's probably a good idea to rely on those.
If you want to provide your own instructions for a specific module, organize
the build directory in a following way, e.g. for geoip2 module:

```
docker-nginx/modules $ tree geoip2
geoip2
├── build-deps
├── prebuild
└── source

0 directories, 3 files
```

The scripts expect one file to always exist for a module you wish to build
manually: `source`.  It should contain a link to a zip/tarball source code of a
module you want to build.  In `build-deps` you can specify build dependencies
for a module as found in the Debian 10 Buster repositories.  `prebuild` is a
shell script (make it `chmod +x prebuild`) that will be executed prior to
building the module but after installing the dependencies.  It can be used to
install additional build dependencies if they are not available from Debian.
Keep in mind that those dependencies wont be automatically copied to the
resulting image and if you're building a library, build it statically.

Once the build is done in the builder image, the built packages are copied over
to resulting image and installed via apt.  The resulting image will be tagged
and can be used the same way as official docker hub image.

