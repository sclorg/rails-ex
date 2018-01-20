

<!-- toc -->

- [Rails App on OpenShift for a little expose on Mars](#rails-app-on-openshift-for-a-little-expose-on-mars)
  * [Students](#students)
    + [Dimitri](#dimitri)
    + [Teu](#teu)
  * [Development](#development)
    + [Compatibility](#compatibility)
    + [License](#license)

<!-- tocstop -->

Rails App on OpenShift for a little expose on Mars
==================================================

This is a quickstart Rails application for OpenShift v3 that you can use as a starting point to develop your own application and deploy it on an [OpenShift](https://github.com/openshift/origin) cluster.

If you'd like to install it, follow [these directions](https://github.com/openshift/rails-ex/blob/master/README.md#installation).  

The steps in this document assume that you have access to an OpenShift deployment that you can deploy applications on.

Students
------------------------
List of students:
*  Dimitri
*  Teu

### Dimitri
Info :

### Teu
Since

Development
------------------------
When you develop your Rails application in OpenShift, you can also enable the 'development' environment by setting the RAILS_ENV environment variable for your deploymentConfiguration, using the `oc` client, like:  

		$ oc env dc/rails-postgresql-example RAILS_ENV=development


If you do so, OpenShift will run your application under 'development' mode. In development mode, your application will:  


Development environment can help you debug problems in your application in the same way as you do when developing on your local machine. However, we strongly advise you to not run your application in this mode in production.



### Compatibility

This repository is compatible with Ruby 2.3 and higher, excluding any alpha or beta versions.

### License
This code is dedicated to the public domain to the maximum extent permitted by applicable law, pursuant to [CC0](http://creativecommons.org/publicdomain/zero/1.0/).
