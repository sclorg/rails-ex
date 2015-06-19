Rails Sample App on OpenShift
============================

This is a quickstart Rails application for OpenShift v3 that you can use as a starting point to develop your own application and deploy it on an [OpenShift](https://github.com/openshift/origin) cluster.

If you'd like to install it, follow [these directions](https://github.com/openshift/rails-ex/blob/master/README.md#installation).  

In order to access the example blog application, you have to remove the
`public/index.html` which serves as the welcome page. Another option is to make a
request directly to `/articles` which will give you access to the blog.

The username/pw used for authentication in this application are openshift/secret.

The following steps assume that you have access to an OpenShift deployment; you must have an OpenShift deployment that you have access to in order to deploy this app.

OpenShift Considerations
------------------------
These are some special considerations you may need to keep in mind when running your application on OpenShift.

###Assets
Your application is set to precompile the assets every time you push to OpenShift.
Any assets you commit to your repo will be preserved alongside those which are generated during the build.

By adding the ```DISABLE_ASSET_COMPILATION=true``` environment variable value to your BuildConfig, you will disable asset compilation upon application deployment.  See the [BuildConfig](http://docs.openshift.org/latest/dev_guide/builds.html#buildconfig-environment) documentation on setting environment variables for builds in OpenShift V3.

###Security
Since these quickstarts are shared code, we had to take special consideration to ensure that security related configuration variables are unique across applications. To accomplish this, we modified some of the configuration files. Now instead of using the same default values, OpenShift can generate these values using the generate from logic defined within the template.

OpenShift stores these generated values in configuration files that only exist for your deployed application and not in your code anywhere. Each of them will be unique so initialize_secret(:a) will differ from initialize_secret(:b) but they will also be consistent, so any time your application uses them (even across reboots), you know they will be the same.

TLDR: OpenShift can generate and expose environment variables to our application automatically. Look at this quickstart for an example.

###Development mode
When you develop your Rails application in OpenShift, you can also enable the 'development' environment by setting the RAILS_ENV environment variable for your deploymentConfiguration, using the `oc` client, like:  

		$ oc env dc/frontend RAILS_ENV=development


If you do so, OpenShift will run your application under 'development' mode. In development mode, your application will:  
*  Show more detailed errors in the browser  
*  Skip static assets (re)compilation  

Development environment can help you debug problems in your application in the same way as you do when developing on your local machine. However, we strongly advise you to not run your application in this mode in production.

###Installation: 
These steps assume your OpenShift deployment has the default set of ImageStreams defined.  Instructions for installing the default ImageStreams are available [here](http://docs.openshift.org/latest/admin_guide/install/first_steps.html)

1. Fork a copy of [rails-ex](https://github.com/openshift/rails-ex)
2. Clone your repository to your development machine
3. Add a Ruby application from the rails template:

		$ oc process -f openshift/templates/rails-postgresql.json -v=SOURCE_REPOSITORY_URL=https://github.com/yourusername/rails-ex | oc create -f - 

4. Note that creating from a template will automatically start a new build. Watch your build progress:

		$ oc build-logs rails-example-1

5. Wait for frontend pods to start up (this can take a few minutes):  

		$ oc get pods -w


	Sample output:  

		NAME                    READY     REASON         RESTARTS   AGE
		rails-example-1-build   1/1       Running        0          2m
		NAME                      READY     REASON    RESTARTS   AGE
		rails-frontend-1-deploy   0/1       Pending   0          0s
		rails-frontend-1-deploy   0/1       Running   0         2s
		rails-frontend-1-prehook   0/1       Pending   0         0s
		rails-frontend-1-deploy   1/1       Running   0         3s
		rails-example-1-build   0/1       ExitCode:0   0         2m
		rails-frontend-1-prehook   0/1       Running   0         6s
		rails-frontend-1-prehook   0/1       ExitCode:0   0         10s
		rails-frontend-1-xlqrp   0/1       Pending   0         0s
		rails-frontend-1-xlqrp   0/1       Running   0         1s
		rails-frontend-1-xlqrp   1/1       Running   0         11s
		rails-frontend-1-deploy   0/1       ExitCode:0   0         24s
		rails-frontend-1-prehook   0/1       ExitCode:0   0         22s



6. Check the IP and port the frontend service is running on:  

		$ oc get svc


	Sample output:  

		NAME             LABELS                              SELECTOR              IP(S)           PORT(S)
		rails-frontend   template=rails-example   name=rails-frontend   172.30.161.15   8080/TCP

In this case, the IP for frontend is 172.30.161.15 and it is on port 8080.  
*Note*: you can also get this information from the web console.


###Adding Webhooks and Making Code Changes
Since OpenShift V3 does not provide a git repository out of the box, you can configure your github repository to make a webhook call whenever you push your code.

1. From the console navigate to your project  
2. Click on Browse > Builds  
3. From the view for your Build click on the link to display your GitHub webhook and copy the url.  
4. Navigate to your repository on GitHub and click on repository settings > webhooks  
5. Paste your copied webhook url provided by OpenShift - Thats it!  
6. After you save your webhook, if you refresh your settings page you can see the status of the ping that Github sent to OpenShift to verify it can reach the server.  

###License
This code is dedicated to the public domain to the maximum extent permitted by applicable law, pursuant to [CC0](http://creativecommons.org/publicdomain/zero/1.0/).
