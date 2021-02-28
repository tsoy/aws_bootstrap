const {hostname} = require('os')
const http = require('http')

const message = "Hell no, world"
const port = 8080
const server = http.createServer((req, res) => {
    res.statusCode = 200
    res.setHeader('Content-Type', 'text/plain')
    res.end(message)
})

server.listen(port, hostname, () => {
    console.log(`Server running on http://${hostname()}:${port}/`)
})