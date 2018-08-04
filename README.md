# puppeteer-lambda
## Using Amazon Lambda + Headless Chrome + Puppeteer to test HTML5 client

This work is based on the [chromeless](https://github.com/prismagraphql/chromeless) work.

For the above repository and setup Chromeless.  If you don't already have the CHROMELESS_ENDPOINT_URL and CHROMELESS_ENDPOINT_API_KEY you'll need to go through the installation steps for [https://github.com/prismagraphql/chromeless#proxy-setup](proxy setup).

Once setup, create a file `env.sh` that has the following two environment variables

~~~
#!/bin/bash -e

export CHROMELESS_ENDPOINT_URL=https://...
export CHROMELESS_ENDPOINT_API_KEY=...
~~~

Next, use API mate to create a `creat` URL and `join` URL for a session.   Edit gather.sh to put the `create` URL at the top (this will call it once) as in

~~~
wget -O- -q 'http://test-install.blindsidenetworks.com/bigbluebutton/api/create?allowStartStopRecording=true&attendeePW=ap&autoStartRecording=false&joinViaHtml5=true&meetingID=random-4450177&moderatorPW=mp&name=random-4450177&record=false&voiceBridge=79347&welcome=%3Cbr%3EWelcome+to+%3Cb%3E%25%25CONFNAME%25%25%3C%2Fb%3E%21&checksum=25b883198de699ec31bfd63341b602072ea55ddd' > /dev/null
~~~

 and edit run.js to add the `join` URL.

~~~
  const screenshot = await chromeless
    .goto('https://s100.freddixon.ca/bigbluebutton/api/join?fullName=User+8730923&joinViaHtml5=true&meetingID=random-444599&password=mp&redirect=true&checksum=9e37c0d323a01a5cc844b12569088c042c917af1')
    .wait(60000)
    .screenshot()
~~~

You can then test by running the script with

~~~
./run.sh
~~~

If successful, you'll see the results of the execution of chrome on Lambda.  

~~~
firstuser@Utopia-01:~/dev/puppeteer-lambda$ ./run.sh
'https://048936999881-us-east-1-chromeless.s3.amazonaws.com/cjkenpfjl000101rwtjshlqhu.png',
~~~

## Running at scale 

To run lots of tests in parallel, edit `gather.sh` and modify the number of clients

~~~
while [ $COUNTER -lt 100 ]; do
~~~

and the warmup time (a random sleep value for each invocation of chromeless so all users are not joining at once).  Here the time is 30 seconds before running `run.sh`.

~~~
  timeout 120 sleep $(( ( RANDOM % 30 )  + 1 )) && ./run.sh >> /tmp/out.txt &
~~~

After your execute `gather.sh`, there will be an `index.html` file that references the screenshot for every image.  Open this file in a browser to see the results of the tests.




