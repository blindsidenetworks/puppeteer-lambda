# puppeteer-lambda

We want to test the HTML5 client with large numbers of users.  With the help of [chromeless](https://github.com/prismagraphql/chromeless), we can launch hundreds of chrome instances via Amazon Lambda.  

To run a single instance, the file `run.sh` runs headless Chrome on Lambda and outputs a URL for the screenshot. 

~~~
#!/bin/bash -e

source env.sh

url=`nodejs ./run.js`
echo "'$url',"
~~~

The file `env.sh` holds the


Wrote another script called gather.sh which executes N run.sh scripts, pipes the URLS to a file, then creates an index.html page with all the URLs.

Between each test I restarted the meeting (but not the server).
I started drawing when all users joined, then stopped drawing when the last user left

Tested on a 4 Core Digital Ocean VM with 8G of memory running the latest build of BigBlueButton 2.0-RC3.


Generate 

## Running the script

First, clone the [chromeless](https://github.com/prismagraphql/chromeless) and go through the setup steps.  You can run it locally with Crhome to test.  Next, go through the installation steps for [https://github.com/prismagraphql/chromeless#proxy-setup](proxy setup).  This will give you a `CHROMELESS_ENDPOINT_URL` and `CHROMELESS_ENDPOINT_API_KEY`.

Next, create a file `env.sh` that has the following two environment variables

~~~
#!/bin/bash -e

export CHROMELESS_ENDPOINT_URL=https://...
export CHROMELESS_ENDPOINT_API_KEY=...
~~~

Save this into the same directory as `run.sh`.

Next, use API mate to create a `create` URL and `join` URL for the HTML5 session.  Pass the customer variable `joinViaHtml5=true`.  Edit `gather.sh` to put the `create` URL at the top (this will call it once) as in

~~~
wget -O- -q 'http://test.example.com/bigbluebutton/api/create?allowStartStopRecording=true&attendeePW=ap&autoStartRecording=false&joinViaHtml5=true&meetingID=random-4450177&moderatorPW=mp&name=random-4450177&record=false&voiceBridge=79347&welcome=%3Cbr%3EWelcome+to+%3Cb%3E%25%25CONFNAME%25%25%3C%2Fb%3E%21&checksum=XXX' > /dev/null
~~~

Next, edit `run.js to` add the `join` URL.

~~~
  const screenshot = await chromeless
    .goto('https://test.example.com/bigbluebutton/api/join?fullName=User+8730923&joinViaHtml5=true&meetingID=random-444599&password=mp&redirect=true&checksum=9e37c0d323a01a5cc844b12569088c042c917af1')
    .wait(60000)
    .screenshot()
~~~

You can then test to run a single instance with

~~~
./run.sh
~~~

If successful, you'll see the results of the execution of chrome on Lambda.  

~~~
firstuser@server.com:~/dev/puppeteer-lambda$ ./run.sh
'https://048936999881-us-east-1-chromeless.s3.amazonaws.com/cjkenpfjl000101rwtjshlqhu.png',
~~~

## Running at scale 

To run lots of tests in parallel, edit `gather.sh` and modify the number of clients it executes.

~~~
while [ $COUNTER -lt 100 ]; do
~~~

Change 100 to whatever value you wish.  Next, edit the warmup time (a random sleep value for each invocation of chromeless so all users are not joining at once).  Here the time is 30 seconds before running `run.sh`.

~~~
  timeout 120 sleep $(( ( RANDOM % 30 )  + 1 )) && ./run.sh >> /tmp/out.txt &
~~~
After your execute `gather.sh`, it will generate a local  `index.html` file that references the screenshot for every image.  Open this file in a browser to see the results of the tests.

For example, after starting 100 clients, login with an HTML5 client (using the URL you added to `run.js`.  As the puppeteer clients load, try drawing on the screen.

![drawing](/images/drawing.png)

All the clients should display the numbers exactly.  After the clients exit, open the generated `index.html` to see what the last screen shot was for each client.

![last](/images/screen-shot.png)





