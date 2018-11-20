#!/bin/bash 

#
# Ogre II
#


usage() {
    cat 1>&2 <<HERE

Script to stress test BigBlueButton using Lambda.

USAGE

  ./gather.sh [OPTIONS]

OPTIONS (install)

  -c <number>		Target for <number> of concurrent users
HERE
}


main() {
 while builtin getopts "hc:" opt "${@}"; do
    case $opt in
      h)
        usage
        exit 0
        ;;

      c)
        COUNT=$OPTARG
        run_series
        ;;

      :)
        err "Missing option argument for -$OPTARG"
        exit 1
        ;;

      \?)
        err "Invalid option: -$OPTARG" >&2
        usage
        ;;
    esac
  done

  if [ -z "$VERSION" ]; then
    usage
    exit 0
  fi
}

run_series() {
  COUNTER=0
  while [ $COUNTER -lt $COUNT ]; do
    let COUNTER=COUNTER+1

    spawn $COUNTER
    sleep 10
  done
}

spawn() {
  TARGET=$1

  wget -O- -q 'https://s150.meetbbb.com/bigbluebutton/api/create?allowStartStopRecording=true&attendeePW=ap&autoStartRecording=false&joinViaHtml5=true&meetingID=random-1859718&moderatorPW=mp&name=random-1859718&record=false&voiceBridge=74515&welcome=%3Cbr%3EWelcome+to+%3Cb%3E%25%25CONFNAME%25%25%3C%2Fb%3E%21&checksum=10862faf8e94ff0460242867b11a2904766d2ffc' > /dev/null

  rm -f /tmp/out.txt

  pids=()

  COUNTER=0
  while [ $COUNTER -lt $TARGET ]; do
    let COUNTER=COUNTER+1 

    timeout 120 sleep $(( ( RANDOM % 10 )  + 1 )) && ./run.sh >> /tmp/out.txt &

    pids+=($!)
  done

  wait "${pids[@]}"
  # echo "$(date +%H:%M:%S): Done!"
  echo "$TARGET,$(grep true /tmp/out.txt | wc | sed 's/ [ ]*/ /g' | cut -d' ' -f2)"
}

gen_index() { 
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
}

main "$@" || exit 1

