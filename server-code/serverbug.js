const http = require('http')
const querystring = require('querystring')
var password = '{"password" : "this is password 1"}'
var password2 = '{"password" : "this is password 1"}'
var wifiName = '{"password" : "this is name"}'

// set port
const PORT = 9000;

    // create server
const server = http.createServer((req, res) => {
    // receive URL of request
    const url = req.url
    // receive method of request
    const method = req.method
    // transform the part of url after ? in to object
    const query = querystring.parse(url.split('?')[1])
    const contentType = req.headers['content-type']

    // set return data in json format.
    res.setHeader('content-type', 'application/json')

    if (method === 'GET') {
        // return data
        let resData = {}
        if (query.id === '1'){resData = {'password': password}}
        if (query.id === '2'){resData = {'password': password2}}
        if (query.id === '3'){resData = {'password': wifiName}}
        else{resData = {'password': 'no such id'}}
           // tranform object into json object
           res.end(JSON.stringify(resData));
           return
    }
    if (method === 'POST') {
        /*if (contentType === 'application/json') {
            let postData = '';
            req.on('data', (chunk) => {
                // chunk is not string so needs to be trans to string
                postData += chunk;
         })
        req.on('end', () => {
            const query = querystring.parse(postData)
            password = JSON.stringify(query)
            res.writeHead(200, {'content-type': 'application/json'});
            res.write(password)
            res.end()
        })
        return
        }
        if(contentType === 'text/plain') {
            res.writeHead(200, {'content-type': 'text/plain'});
            res.write('you have sent a string bro!!!\n')
            res.end()
            return
        }*/
        let postData = '';
            req.on('data', (chunk) => {
                // chunk is not string so needs to be trans to string
                postData += chunk;
         })
           req.on('end', () => {
            let transData = JSON.parse(postData.toString());
            console.log(transData);
            let resData2 = {}
            if (query.id === '1'){ 
                password = transData.password; 
                resData2 = {'password': password}
                res.write(JSON.stringify(resData2))
                res.end()
            }
            if (query.id === '2'){ 
                password2 = transData.password;
                resData2 = {'password': password2}
                res.write(JSON.stringify(resData2))
                res.end()
            }
            if (query.id === '3'){ 
                wifiName = transData.password;
                resData2 = {'password': wifiName}
                res.write(JSON.stringify(resData2))
                res.end()
            }
            else{
                resData2 = {'password': 'no such id'}
                res.write(JSON.stringify(resData2))
                res.end()
            }
        })
           return
    }
    // if falied to match, return 404 page
    res.writeHead(200, {'content-type': 'text/plain'});
    res.write('404 Not Found\n')
    res.end()
    });

    // set port for server
    server.listen(PORT)

    console.log('node-server started at port http://localhost:' + PORT)
