Rails Sample App on OpenShift
============================

This is a quickstart Rails application for OpenShift v3.

The easiest way to install this application is to use the [OpenShift Instant Application](https://openshift.redhat.com/app/console/application_types).
If you'd like to install it manually, follow [these directions](https://github.com/openshift/rails-ex/blob/master/README#manual-installation).  

The username/pw used for authentication in this application are openshift/secret.

In order to access the example application, you have to remove the
`public/index.html` which serves as the welcome page. Other option is to make a
request directly to `/articles` which will give you access to the blog.

OpenShift Considerations
------------------------
These are some special considerations you may need to keep in mind when running your application on OpenShift.

###Database
Your application is configured to use your OpenShift database in Production mode.  Because it addresses these databases based on
 url, you will need to change these if you want to use your application outside of OpenShift.

###Assets
Your application is set to precompile the assets every time you push to OpenShift.
Any assets you commit to your repo will be preserved alongside those which are generated during the build.

By adding the ```DISABLE_ASSET_COMPILATION=true``` environment variable value, you will disable asset compilation upon application deployment.
See the [development](https://github.com/openshift/rails-ex/blog/master/README#development-mode) section on setting environment variables in OpenShift V3.

###Security
Since these quickstarts are shared code, we had to take special consideration to ensure that security related configuration variables was unique across applications. To accomplish this, we modified some of the configuration files (shown in the table below). Now instead of using the same default values, OpenShift can generate these values using the generate from logic defined within the instant application's template.

OpenShift stores these generated values in configuration files that only exist for your deployed application and not in your code anywhere. Each of them will be unique so initialize_secret(:a) will differ from initialize_secret(:b) but they will also be consistent, so any time your application uses them (even across reboots), you know they will be the same.

TLDR: OpenShift can generate and expose environment variables to our application automatically. Look at this quickstart for an example.

###Development mode
When you develop your Rails application in OpenShift, you can also enable the 'development' environment by setting the RAILS_ENV environment variable for your deploymentConfiguration, using the `oc` client, like:  
`oc env dc/frontend RAILS_ENV=development`  

If you do so, OpenShift will run your application under 'development' mode. In development mode, your application will:  
*  Show more detailed errors in the browser  
*  Skip static assets (re)compilation  
*  Skip web server restart, as the code is reloaded automatically  
*  Skip `bundle` command if the Gemfile is not modified  

Development environment can help you debug problems in your application in the same way as you do when developing on your local machine. However, we strongly advise you to not run your application in this mode in production.

###Manual Installation: 
1. Create an account at [https://www.openshift.com](https://www.openshift.com)  
*NOTE*: OpenShift Online currently is using V2.
2. Fork a copy of [rails-ex](https://github.com/openshift/rails-ex)
3. Clone your repository to your OpenShift server
3. Update the GitHub repository url in the instant app configuration to match your forked url 
2. Add a Ruby application from the rails template
`oc process -f openshift/templates/rails.json | oc create -f - `
3. Start the build  
`oc start-build rails-blog`
4. Watch your build progress  
`oc build-logs -f rails-blog-1`
5. Wait for frontend pods to start up (this can take a few minutes):  
`oc get pods`  
Sample output:  
>POD                IP           CONTAINER(S)   IMAGE(S)                                                                                                            HOST                               LABELS                                                                                             STATUS       CREATED     MESSAGE  
frontend-1-uuc9n   172.17.0.8                                                                                                                                      ip-10-178-206-122/10.178.206.122   deployment=frontend-1,deploymentconfig=frontend,name=frontend                                      Running      7 seconds   
                                rails-blog     172.30.177.53:5000/demo/origin-rails-blog@sha256:94dc559931fcbdbf527b24e95440ae81761cc917f61a47ecefba18b98d9a4003                                                                                                                                         Running      1 seconds   
rails-blog-1                                                                                                                                                       ip-10-178-206-122/10.178.206.122   build=rails-blog-1,buildconfig=rails-blog,name=rails-blog,template=application-template-stibuild   Succeeded    5 minutes   
                                sti-build      openshift/origin-sti-builder:v0.5.1                                                                                                                                                                                                                       Terminated   5 minutes   exit code 0  

6. Check the IP and port the frontend service is running on:  
`oc get services`  
Sample output:  
>NAME       LABELS                                   SELECTOR        IP(S)            PORT(S)  
frontend   template=application-template-stibuild   name=frontend   172.30.196.123   5432/TCP  

In this case, the IP for frontend is 172.30.196.123 and it is on port 5432.  
*Note*: you can also get this information from the web console.

###Manual Installation: With PostgreSQL
1. Create an account at [https://www.openshift.com](https://www.openshift.com)  
*NOTE*: OpenShift Online currently is using V2.
2. Fork a copy of [rails-ex](https://github.com/openshift/rails-ex)
3. Clone your repository to your OpenShift server
3. Update the GitHub repository url in the instant app configuration to match your forked url 
2. Add a Ruby application from the rails-postgresql template
`oc process -f openshift/templates/rails-postgresql.json | oc create -f - `
3. Start the build  
`oc start-build rails-blog`
4. Watch your build progress  
`oc build-log -f rails-blog-1`  
5. Wait for frontend and database pods to be started (this can take a few minutes):  
`oc get pods`  
Sample output:  
>POD                                IP            CONTAINER(S)          IMAGE(S)                                                                                                            HOST                               LABELS                                                                                             STATUS       CREATED      MESSAGE
database-1-ablzw                   172.17.0.10                                                                                                                                             ip-10-178-206-122/10.178.206.122   deployment=database-1,deploymentconfig=database,name=database                                      Running      3 minutes    
                                                 rails-blog-database   openshift/postgresql-92-centos7                                                                                                                                                                                                                           Running      3 minutes    
deployment-frontend-1-hook-yw8h3   172.17.0.15                                                                                                                                             ip-10-178-206-122/10.178.206.122   <none>                                                                                             Succeeded    35 seconds   
                                                 lifecycle             172.30.177.53:5000/test/origin-rails-blog@sha256:3db0e26862c34b86bb70151870bb22fbfe201dd9f37ee7d72985ba08cec8abde                                                                                                                                         Terminated   29 seconds   exit code 0
frontend-1-k5hpm                   172.17.0.14                                                                                                                                             ip-10-178-206-122/10.178.206.122   deployment=frontend-1,deploymentconfig=frontend,name=frontend                                      Running      35 seconds   
                                                 rails-blog            172.30.177.53:5000/test/origin-rails-blog@sha256:3db0e26862c34b86bb70151870bb22fbfe201dd9f37ee7d72985ba08cec8abde                                                                                                                                         Running      30 seconds   
rails-blog-1                                                                                                                                                                               ip-10-178-206-122/10.178.206.122   build=rails-blog-1,buildconfig=rails-blog,name=rails-blog,template=application-template-stibuild   Succeeded    3 minutes    
                                                 sti-build             openshift/origin-sti-builder:v0.5.1                                                                                                                                                                                                                       Terminated   3 minutes    exit code 0

6. Check the IP and port the frontend service is running on:  
`oc get services`  
Sample output:  
>NAME       LABELS                                   SELECTOR        IP(S)            PORT(S)
database   template=application-template-stibuild   name=database   172.30.49.70     5434/TCP
frontend   template=application-template-stibuild   name=frontend   172.30.104.173   5432/TCP
  
In this case, the IP for frontend is 172.30.104.173 and it is on port 5432.  
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
