const { Chromeless } = require('chromeless')

async function run() {
   const chromeless = new Chromeless({ remote: true })
// const chromeless = new Chromeless()

  const screenshot = await chromeless
    .goto('http://test-install.blindsidenetworks.com/bigbluebutton/api/join?fullName=User+4008077&joinViaHtml5=true&meetingID=random-4450177&password=mp&redirect=true&checksum=07c28282a75ca1220ba130052f58190df9d8a703')
    .wait(6000)
    .screenshot()

  console.log(screenshot) // prints local file path or S3 url

  await chromeless.end()
}

run().catch(console.error.bind(console))


