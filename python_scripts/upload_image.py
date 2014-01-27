import json,httplib,urllib

files = ['tall.jpg', 'dark.jpg', 'handsome.jpg']
output = []
connection = httplib.HTTPSConnection('api.parse.com', 443)
connection.connect()

for file in files: 
    connection.request('POST', '/1/files/' + file, open(file, 'rb').read(), {"X-Parse-Application-Id": "tnfagd2VTU7mWgfquIIx8wcE6S8mrjG59nfoPP1q","X-Parse-REST-API-Key": "MQYLPDDZw8IfwWGKqw6xI2gmMeneUWKRncBttEAI","Content-Type": "application/json"})
    result = json.loads(connection.getresponse().read())
    print result['name']
    output.append(result['name'])

print output

connection.request('PUT', '/1/classes/Question/e4BnQd6n01', json.dumps({
       "optionImages": output
     }), {
       "X-Parse-Application-Id": "tnfagd2VTU7mWgfquIIx8wcE6S8mrjG59nfoPP1q",
       "X-Parse-REST-API-Key": "MQYLPDDZw8IfwWGKqw6xI2gmMeneUWKRncBttEAI",
       "Content-Type": "application/json"
     })
result = json.loads(connection.getresponse().read())
print result