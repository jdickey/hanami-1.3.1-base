# Base Images for [Hanami](http://hanamirb.org/) 1.3.1

# Contents

* [Overview](#overview)
* [IMPORTANT NOTES](#important-notes)
  * [Silent Gem Version Updates](#silent-gem-version-updates)
  * [Alpine Linux Version](#alpine-linux-version)
  * [No Qt\-included Image Variants](#no-qt-included-image-variants)
* [Building and Tagging the Images](#building-and-tagging-the-images)
* [Images and Supported Tags](#images-and-supported-tags)
  * [Debian Stretch Images](#debian-stretch-images)
    * [With hanami\-model](#with-hanami-model)
    * [Without hanami\-model](#without-hanami-model)
  * [Debian Slimmed\-down Stretch Images](#debian-slimmed-down-stretch-images)
    * [Without hanami\-model](#without-hanami-model-1)
  * [Alpine 3\.9 Images](#alpine-39-images)
    * [With hanami\-model](#with-hanami-model-1)
    * [Without hanami\-model](#without-hanami-model-2)
* [Gems Installed](#gems-installed)
  * [All Images](#all-images)
  * [Images Not Tagged \*\-no\-hm](#images-not-tagged--no-hm)
* [Additional Documentation](#additional-documentation)
* [Legal](#legal)


# Overview

These images are built from [`jdickey`](https://hub.docker.com/r/jdickey/ruby/)'s [Customised Ruby Builds](https://github.com/jdickey/docker-ruby), with tags matching *a subset of* [those in the base image](https://hub.docker.com/r/jdickey/docker-ruby/README.md#supported-tags-and-respective-dockerfile-links). This leads to a bit of complexity, as we now have three significant (conceptual) versioned layers that the users of these images should care about: the base operating system (Debian or Alpine); the version of Ruby being used (currently, 2.6.3 and 2.5.5); and the version of the Hanami framework (here, Version 1.3.1; current as of this writing). Encoding all three version identifiers into a single tag name could lead to tags such as `1.3.1-stretch-2.6.3` or, worse, `1.3.1-2.6.3` (implying "whatever the current default base OS is"). Does anyone *not* have problems with this? Hence, this repo will concern itself with *only* Hanami 1.3.1; future releases of Hanami are expected to be supported by congruently-structured and -tagged *but separate* Docker image repos, as had previously been done for Hanami 1.1.0, 1.1.1, and 1.2.0.

# IMPORTANT NOTES

## Silent Gem Version Updates

No release of these images will be tagged that *only* updates Gem versions, without changes to either the list of Gems installed or the process of building these images. At least one of those two things must change to justify a new version tag. This is in contrast to the historical practice of previous, now-withdrawn base images for Hanami.

## Alpine Linux Version

The Alpine builds of these images presently (16 May 2019) are based upon [Alpine Linux 3.9.4](https://alpinelinux.org/posts/Alpine-3.9.4-released.html). The [CVE-2019-5021](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-5021) vulnerability [*does not apply*](https://alpinelinux.org/posts/Docker-image-vulnerability-CVE-2019-5021.html) to this version, nor to images built upon it.

## No Qt-included Image Variants

Historical releases of [`jdickey`](https://hub.docker.com/r/jdickey/ruby/)'s [Customised Ruby Builds](https://github.com/jdickey/docker-ruby) included variants which included the Qt window manager, `capybara-webkit`, and the supporting `json` Gem; discernible from the no-Qt-included variants by the inclusion of `-qt` in their image tags. Since this practice was discontinued with effect from [Version 0.17.0](https://github.com/jdickey/docker-ruby/#0170-24-february-2019) of the base image, predating the first release of these images, no such `-qt` (or `-no-qt`) variants appear here.

# Building and Tagging the Images

To build the images, we use a Ruby CLI-driven script that first dynamically builds a sequence of in-memory `Dockerfile` text sequences, and then builds the images dynamically using the [`docker-api`](https://github.com/swipely/docker-api) Gem. While building the `Dockerfile` for a particular image, a sequence of `gem install` commands is `RUN` based on whether the image is or is not built with the `hanami-model` Gem. **Note that** unlike our base images for previous versions of Hanami, *we no longer build images* which include the Qt GUI toolkit or the Ruby `capybara` Gem, both of which were used by the `capybara-webkit` headless-browser testing tool. We now recommend use of a *separate image* for such testing, following a setup similar to [that described by Ahmet Kizilay](https://ahmetkizilay.com/2016/02/07/dockerized-selenium-testing-with-capybara.html). This provides maximum flexibility with minimum (zero) additional bloat of this image.

Each built image encodes three items of information about itself into its image name:

1. the version of Ruby installed in the image (currently, MRI 2.6.3 or 2.5.5);

2. the base operating system used to build the image (Debian Stretch, slimmed-down Debian Stretch, or Alpine 3.9); and

3. whether the image includes the `hanami-model` Gem and its supporting Gems (but *not* any specific database-access Gems such as `sqlite` or `pg`).

Examples might be `2.6.5-alpine3.9-hm` or `2.5.5-stretch-no-hm`.

Additional tags are created as synonyms for the as-built tags. For example, the `2.5-alpine-hm` tag refers to the *latest* 2.5.*x* Ruby version (currently, 2.5.5), built using the latest supported Alpine Linux base OS image. Similarly, the `2-no-hm` tag refers to the latest 2.*x* version of Ruby, which is presently 2.6.3, built on Debian Stretch. Finally, tags which do not name a particular base OS (e.g., `stretch`, or `alpine`) refer to what has been designated the "default" for a specific Ruby version, which is *generally* in accordance with the defaults for the [official Ruby images](https://hub.docker.com/_/ruby/). `2.6` is a synonym for `2.6.1-stretch-hm`.

**Note that** it is not unusual for projects to use different base images for development and testing than for staging and production; Debian, even in its slimmed-down form, is still a *huge* image compared to Alpine. Alpine is not even the smallest container-targeted base image; that is presently being contested between Canonical's [CirrOS](https://launchpad.net/cirros) ([Docker Hub link](https://hub.docker.com/_/cirros/)) and [BusyBox](https://www.busybox.net/) ([Docker Hub link](https://hub.docker.com/_/busybox)).

Early builds of this image provided the option of including Capybara for use in testing; this increased image size *dramatically* by including its dependencies (e.g., the Qt GUI toolkit and its required OS support). Since this practice was discontinued with effect from [Version 0.17.0](https://github.com/jdickey/docker-ruby/#0170-24-february-2019) of the base image, the differentiation between production use, where size matters, and development use *within a given base OS* has largely disappeared.

# Images and Supported Tags

**Note that** it is **recommended** that, after starting from a specific tag such as `2.6.3-stretch-slim-hm` during initial development through to production, that you iteratively decrease specificity of your base-image tag as succeeding versions of these base images are released; continuing the example to a hypothetical Ruby 2.6.4-based release, testing against `2.6-stretch-slim-hm` and then, when Ruby 2.7 is released (anticipated in late 2019), moving to `2-stretch-slim-hm` or simply `stretch-slim`. Then, running your comprehensive test suite, you will be able to identify any breakage in your code induced by the new Ruby version, planning and executing repairs well before Ruby 2.6's end-of-life (variously projected as mid-2021 to late 2022). Similarly, using `slim` and rebuilding after release of [Debian Buster]-based images will help keep your project healthy with respect to the underlying OS.

## Debian Stretch Images

### With `hanami-model`

| Tag | Details |
| --- | ------- |
| `latest` | Synonym for `2.6.3-stretch-hm` |
| `2` | Synonym for `2.6.3-stretch-hm` |
| `hm` | Synonym for `2.6.3-stretch-hm` | 
| `stretch` | Synonym for `2.6.3-stretch-hm` |
| `stretch-hm` | Synonym for `2.6.3-stretch-hm` |
| `2-stretch` | Synonym for `2.6.3-stretch-hm` |
| `2-stretch-hm` | Synonym for `2.6.3-stretch-hm` |
| `2.6-stretch` | Synonym for `2.6.3-stretch-hm` |
| `2.6-stretch-hm` | Synonym for `2.6.3-stretch-hm` |
| `2.6.3-stretch` | Synonym for `2.6.3-stretch-hm` |
| `2.6.3-stretch-hm` | Ruby 2.6.3 on Debian 9 "Stretch", with `hanami-model` |
| `2.5-stretch` | Synonym for `2.5.5-stretch-hm` |
| `2.5-stretch-hm` | Synonym for `2.5.5-stretch-hm` |
| `2.5.5-stretch` | Synonym for `2.5.5-stretch-hm` |
| `2.5.5-stretch-hm` | Ruby 2.5.5 on Debian 9 "Stretch", with `hanami-model` |


### Without `hanami-model`

| Tag | Details |
| --- | ------- |
| `no-hm` | Synonym for `2.6.3-stretch-no-hm` |
| `stretch-no-hm` | Synonym for `2.6.3-stretch-no-hm` |
| `2-stretch-no-hm` | Synonym for `2.6.3-stretch-no-hm` |
| `2.6-stretch-no-hm` | Synonym for `2.6.3-stretch-no-hm` |
| `2.6.3-stretch-no-hm` | Ruby 2.6.3 on Debian 9 "Stretch", without `hanami-model` |
| `2.5-stretch-no-hm` | Synonym for `2.5.5-stretch-no-hm` |
| `2.6.3-stretch-no-hm` | Ruby 2.5.5 on Debian 9 "Stretch", without `hanami-model` |


## Debian Slimmed-down Stretch Images

| Tag | Details |
| --- | ------- |
| `stretch-slim` | Synonym for `2.6.3-stretch-slim-hm` |
| `stretch-slim-hm` | Synonym for `2.6.3-stretch-slim-hm` |
| `2-stretch-slim` | Synonym for `2.6.3-stretch-slim-hm` |
| `2-stretch-slim-hm` | Synonym for `2.6.3-stretch-slim-hm` |
| `2.6-stretch-slim` | Synonym for `2.6.3-stretch-slim-hm` |
| `2.6-stretch-slim-hm` | Synonym for `2.6.3-stretch-slim-hm` |
| `2.6.3-stretch-slim` | Synonym for `2.6.3-stretch-slim-hm` |
| `2.6.3-stretch-slim-hm` | Ruby 2.6.3 on 'slim' Debian 9 "Stretch", with `hanami-model` |
| `2.5-stretch-slim` | Synonym for `2.5.5-stretch-slim-hm` |
| `2.5-stretch-slim-hm` | Synonym for `2.5.5-stretch-slim-hm` |
| `2.5.5-stretch-slim` | Synonym for `2.5.5-stretch-slim-hm` |
| `2.5.5-stretch-slim-hm` | Ruby 2.5.5 on 'slim' Debian 9 "Stretch", with `hanami-model` |


### Without `hanami-model`

| Tag | Details |
| --- | ------- |
| `stretch-slim-no-hm` | Synonym for `2.6.3-stretch-slim-no-hm` |
| `2-stretch-slim-no-hm` | Synonym for `2.6.3-stretch-slim-no-hm` |
| `2.6-stretch-slim-no-hm` | Synonym for `2.6.3-stretch-slim-no-hm` |
| `2.6.3-stretch-slim-no-hm` | Ruby 2.6.3 on 'slim' Debian 9 "Stretch", without `hanami-model` |
| `2.5-stretch-slim-no-hm` | Synonym for `2.5.5-stretch-slim-no-hm` |
| `2.6.3-stretch-slim-no-hm` | Ruby 2.5.5 on 'slim' Debian 9 "Stretch", without `hanami-model` |

## Alpine 3.9 Images

### With `hanami-model`

| Tag | Details |
| --- | ------- |
| `alpine` | Synonym for `2.6.3-alpine3.9-hm` |
| `alpine-hm` | Synonym for `2.6.3-alpine3.9-hm` |
| `alpine3.9` | Synonym for `2.6.3-alpine3.9-hm` |
| `alpine3.9-hm` | Synonym for `2.6.3-alpine3.9-hm` |
| `alpine39` | Synonym for `2.6.3-alpine3.9-hm` |
| `alpine39-hm` | Synonym for `2.6.3-alpine3.9-hm` |
| `2-alpine` | Synonym for `2.6.3-alpine3.9-hm` |
| `2-alpine-hm` | Synonym for `2.6.3-alpine3.9-hm` |
| `2-alpine3.9` | Synonym for `2.6.3-alpine3.9-hm` |
| `2-alpine3.9-hm` | Synonym for `2.6.3-alpine3.9-hm` |
| `2-alpine39` | Synonym for `2.6.3-alpine3.9-hm` |
| `2-alpine39-hm` | Synonym for `2.6.3-alpine3.9-hm` |
| `2.6-alpine` | Synonym for `2.6.3-alpine3.9-hm` |
| `2.6-alpine-hm` | Synonym for `2.6.3-alpine3.9-hm` |
| `2.6-alpine3.9` | Synonym for `2.6.3-alpine3.9-hm` |
| `2.6-alpine3.9-hm` | Synonym for `2.6.3-alpine3.9-hm` |
| `2.6-alpine39` | Synonym for `2.6.3-alpine3.9-hm` |
| `2.6-alpine39-hm` | Synonym for `2.6.3-alpine3.9-hm` |
| `2.6.3-alpine` | Synonym for `2.6.3-alpine3.9-hm` |
| `2.6.3-alpine-hm` | Synonym for `2.6.3-alpine3.9-hm` |
| `2.6.3-alpine3.9` | Synonym for `2.6.3-alpine3.9-hm` |
| `2.6.3-alpine3.9-hm` | Ruby 2.6.3 on Alpine 3.9, with `hanami-model` |
| `2.6.3-alpine39` | Synonym for `2.6.3-alpine3.9-hm` |
| `2.6.3-alpine39-hm` | Synonym for `2.6.3-alpine3.9-hm` |
| `2.5.5-alpine` | Synonym for `2.5.5-alpine3.9-hm` |
| `2.5.5-alpine-hm` | Synonym for `2.5.5-alpine3.9-hm` |
| `2.5.5-alpine3.9` | Synonym for `2.5.5-alpine3.9-hm` |
| `2.5.5-alpine3.9-hm` | Ruby 2.6.3 on Alpine 3.9, with `hanami-model |
| `2.5.5-alpine39` | Synonym for `2.5.5-alpine3.9-hm` |
| `2.5.5-alpine39-hm` | Synonym for `2.5.5-alpine3.9-hm` |

### Without `hanami-model`

| Tag | Details |
| --- | ------- |
| `alpine-no-hm` | Synonym for `2.6.3-alpine3.9-no-hm` |
| `alpine3.9-no-hm` | Synonym for `2.6.3-alpine3.9-no-hm` |
| `alpine39-no-hm` | Synonym for `2.6.3-alpine3.9-no-hm` |
| `2-alpine-no-hm` | Synonym for `2.6.3-alpine3.9-no-hm` |
| `2-alpine3.9-no-hm` | Synonym for `2.6.3-alpine3.9-no-hm` |
| `2-alpine39-no-hm` | Synonym for `2.6.3-alpine3.9-no-hm` |
| `2.6-alpine-no-hm` | Synonym for `2.6.3-alpine3.9-no-hm` |
| `2.6-alpine3.9-no-hm` | Synonym for `2.6.3-alpine3.9-no-hm` |
| `2.6-alpine39-no-hm` | Synonym for `2.6.3-alpine3.9-no-hm` |
| `2.6.3-alpine-no-hm` | Synonym for `2.6.3-alpine3.9-no-hm` |
| `2.6.3-alpine3.9-no-hm` | Ruby 2.6.3 on Alpine 3.9, without `hanami-model` |
| `2.6.3-alpine39-no-hm` | Synonym for `2.6.3-alpine3.9-no-hm` |
| `2.5.5-alpine-no-hm` | Synonym for `2.5.5-alpine3.9-no-hm` |
| `2.5.5-alpine3.9-no-hm` | Ruby 2.6.3 on Alpine 3.9, without `hanami-model |
| `2.5.5-alpine39-no-hm` | Synonym for `2.5.5-alpine3.9-no-hm` |



# Gems Installed

## All Images

These images install the [`hanami`](http://hanamirb.org) Gem, version 1.3.1, and the `hanami-model` Gem, Version 1.3.2, as well as the *current versions at build time* of:

* `hanami-webconsole`; and
* `dotenv`

Note that:

1. `shotgun` and `minitest` are no longer installed by default in this image. The `shotgun` Gem will eventually be replaced by [`hanami-reloader`](https://github.com/hanami/reloader), as per [this Trello card](https://trello.com/c/o09UafAj/22-remove-support-for-shotgun-and-code-reloading-from-hanami). Hanami, as of 1.3.0, uses `rspec` rather than `minitest` as the default test framework; this image does not commit you to one or the other;
2. Your app **must** include a view-template Gem supported by [Tilt](https://github.com/rtomayko/tilt/) (e.g., `erubis` for Erb, `slim`, or `haml`).

## Images Not Tagged `*-no-hm`

Though these images include `hanami-model` and its dependencies, including `rom` and `rom-repository`, **no database-specific interface Gem is included**. Your app **must** include appropriate Gems for accessing your database engine of choice,  such as [`pg`](https://rubygems.org/gems/pg), [`sqlite3`](https://rubygems.org/gems/sqlite3), or others. By omitting those, these images can be used as the *base* images for apps using *any* Hanami-supported database engine.

**Note** that `hanami-model` currently (up to 1.3.2) *only* supports SQL-based databases, hence `rom-sql`. Also note that the Sequel Gem version is significantly outdated; at this writing, the current version of `sequel` is 5.20.0. Support for ROM (and Sequel) Version 5+ is anticipated for `hanami-model` 2.0.0, expected in 3Q 2019.

# Additional Documentation

See the [README for the `jdickey/ruby` base image](https://hub.docker.com/r/jdickey/ruby/) and the [official Ruby Docker image docs](https://hub.docker.com/_/ruby/).

# Legal

All files in this repository are Copyright © 2019 by Jeff Dickey, and licensed under the MIT License.

As with all Docker images, these also contain other software which may be under other licenses (such as Ruby, Bash, etc from the base images, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
