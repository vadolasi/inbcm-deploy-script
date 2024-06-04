const http = require("http")
const spawn = require("child_process").spawn
const crypto = require("crypto")
const url = require("url")

var secret = process.env.GITHUB_SECRET
var port = 8000

http.createServer(function(req, res) {
  console.log("request received")
  res.writeHead(400, { "Content-Type": "application/json" })

  var path = url.parse(req.url).pathname

  if (path != "/push" || req.method != "POST") {
    const data = JSON.stringify({"error": "invalid request"})
    return res.end(data)
  }

  var jsonString = ""
  req.on("data", function(data) {
    jsonString += data
  })

  req.on("end", function() {
    const hash = "sha1=" + crypto.createHmac("sha1", secret).update(jsonString).digest("hex")
    if (hash != req.headers["x-hub-signature"]) {
      console.log("invalid key")
      const data = JSON.stringify({ "error": "invalid key", key: hash })
      return res.end(data)
    }

    console.log("running hook.sh")

    const deploySh = spawn("sh", ["hook.sh"])
    deploySh.stdout.on("data", function(data) {
      const buff = Buffer.from(data)
      console.log(buff.toString("utf-8"))
    })

    res.writeHead(400, { "Content-Type": "application/json" })

    var data = JSON.stringify({ "success": true })
    return res.end(data)
  })
}).listen(port)

console.log("Server listening at " + port)
