#!/bin/bash 

#
# Ogre II
#

wget -O- -q 'http://test-install.blindsidenetworks.com/bigbluebutton/api/create?allowStartStopRecording=true&attendeePW=ap&autoStartRecording=false&joinViaHtml5=true&meetingID=random-4450177&moderatorPW=mp&name=random-4450177&record=false&voiceBridge=79347&welcome=%3Cbr%3EWelcome+to+%3Cb%3E%25%25CONFNAME%25%25%3C%2Fb%3E%21&checksum=25b883198de699ec31bfd63341b602072ea55ddd' > /dev/null

rm -f /tmp/out.txt

pids=()

COUNTER=0
while [ $COUNTER -lt 100 ]; do
  echo -n '.'

  timeout 120 sleep $(( ( RANDOM % 30 )  + 1 )) && ./run.sh >> /tmp/out.txt &

  pids+=($!)
  let COUNTER=COUNTER+1 
done

wait "${pids[@]}"
echo "$(date +%H:%M:%S): Done!"

cat << HERE > index.html
<!DOCTYPE HTML>
<html>
<header><title>This is title</title></header>

<style type="text/css">
img {
    height: 5%;
    width: 5%;
    background-color: powderblue;
}
</style>

<script>
  var ArrayOfImages = [
HERE

cat /tmp/out.txt >> index.html

cat << HERE >> index.html
  ]; 
  ArrayOfImages.forEach(function(image) {
    var img = document.createElement('img');
    img.src = image;
    document.body.appendChild(img);
  });
</script>

<body>
</body>

</html>

HERE


