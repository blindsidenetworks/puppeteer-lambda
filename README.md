# puppeteer-lambda

We want to test the HTML5 client under load to see how it performs (and find bug quickly).  With the help of [chromeless](https://github.com/prismagraphql/chromeless), we can launch hundreds of chrome instances via Amazon Lambda that load the HTML5 client.  

## Overview

The file `run.sh` runs a single instance headless Chrome on Lambda and outputs a URL for the screenshot. 

~~~
#!/bin/bash -e

source env.sh

url=`nodejs ./run.js`
echo "'$url',"
~~~

The file [run.js](https://github.com/blindsidenetworks/puppeteer-lambda/blob/master/run.js) runs one instance of Chrome on Lambda with a join URL.

To run multiple instances, we wrote a second script called `gather.sh` which executes `run.sh` scripts, pipes the screen shot URLs to a file, then creates an `index.html` page with all the URLs.

Generate 

## Setup

First, clone the [chromeless](https://github.com/prismagraphql/chromeless) and go through its setup steps.  Next, go through the installation steps for [https://github.com/prismagraphql/chromeless#proxy-setup](proxy setup).  This will give you a `CHROMELESS_ENDPOINT_URL` and `CHROMELESS_ENDPOINT_API_KEY`.

Next, create a file `env.sh` that sets up these two environment variables

~~~
#!/bin/bash -e

export CHROMELESS_ENDPOINT_URL=https://...
export CHROMELESS_ENDPOINT_API_KEY=...
~~~

Save this into the same directory as `run.sh`.

# Run a single Chrome instance 

These steps assume you already have a BigBlueButton server setup with the latest build of the HTML5 client.

To run a single test, use the excellent [api mate](http://mconf.github.io/api-mate/) to create a `create` and `join` URL for an HTML5 session o nyour server.  Be sure to configure API Mate to set the customer variable `joinViaHtml5=true` on the `join` URL.  

Next, edit `run.js to` add the `join` URL.

~~~
  const screenshot = await chromeless
    .goto('https://test.example.com/bigbluebutton/api/join?fullName=User+8730923&joinViaHtml5=true&meetingID=random-444599&password=mp&redirect=true&checksum=9e37c0d323a01a5cc844b12569088c042c917af1')
    .wait(60000)
    .screenshot()
~~~

Use API Mate to execute the `create` URL.  Then try running `run.sh` to join a client.

~~~
./run.sh
~~~

If successful, you'll see the results of the execution of chrome on Lambda.  

~~~
firstuser@server.com:~/dev/puppeteer-lambda$ ./run.sh
'https://048936999881-us-east-1-chromeless.s3.amazonaws.com/cjkenpfjl000101rwtjshlqhu.png',
~~~

Open this URL in the browser and you'll see the screen shot of what Chrome was showing just before it quit.

## Running at scale 

To run lots of tests in parallel, edit `gather.sh` and put the `create` URL at the top (this will call it once) as in

~~~
wget -O- -q 'http://test.example.com/bigbluebutton/api/create?allowStartStopRecording=true&attendeePW=ap&autoStartRecording=false&joinViaHtml5=true&meetingID=random-4450177&moderatorPW=mp&name=random-4450177&record=false&voiceBridge=79347&welcome=%3Cbr%3EWelcome+to+%3Cb%3E%25%25CONFNAME%25%25%3C%2Fb%3E%21&checksum=XXX' > /dev/null
~~~

and modify the number of clients it executes.

~~~
while [ $COUNTER -lt 100 ]; do
~~~

Change 100 to whatever value you wish.  Next, edit the warmup time (a random sleep value for each invocation of chromeless so all users are not joining at once).  For example, here the warmup time is 30 seconds before running `run.sh`.

~~~
  timeout 120 sleep $(( ( RANDOM % 30 )  + 1 )) && ./run.sh >> /tmp/out.txt &
~~~

Execute `gather.sh` and this will run all the chome instances in parallel (giving each a 120 seconds to finish), and then generate `index.html` that references the screenshot of each chome instance before it quits.  Open this file in a browser to see the results of the tests.

## Example
First, we installed BigBlueButton 2.0-RC3 on a 4 Core Digital Ocean VM with 8G of memory using [bbb-install.sh](https://github.com/bigbluebutton/bbb-install).

Next, we started starting 100 clients, and, as the clients were starting, logged in with an HTML5 client (using the URL added to `run.js`), and started drawing on the screen.

![drawing](/images/drawing.png)

After the clients exited, we the generated `index.html` to see what the last screen shot was for each client.

![test-results](/images/test-results.png)





