const { Chromeless } = require('chromeless')

// .goto('http://test-install.blindsidenetworks.com/bigbluebutton/api/join?fullName=User+4008077&joinViaHtml5=true&meetingID=random-4450177&password=mp&redirect=true&checksum=07c28282a75ca1220ba130052f58190df9d8a703')
async function run() {
   const chromeless = new Chromeless({ remote: true })
// const chromeless = new Chromeless()

  const screenshot = await chromeless
    .goto('https://s150.meetbbb.com/bigbluebutton/api/join?fullName=User+770173&joinViaHtml5=true&meetingID=random-1859718&password=mp&redirect=true&checksum=9cce7136b96b4b94fb0dc555427c441d013570b2')
    .wait('button[aria-label="Microphone"]')
    .evaluate(() => {
        return document.querySelector('button[aria-label="Microphone"]') != null
    })

  console.log(screenshot) // prints local file path or S3 url

  await chromeless.end()
}

run().catch(console.error.bind(console))


