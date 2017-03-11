"use strict";

console.log('Loading event');
var AWS = require('aws-sdk');
var dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = function(event, context, callback) {
    console.log("Request received:\n", JSON.stringify(event));
    console.log("Context received:\n", JSON.stringify(context));

    if(event.text === undefined || event.timestamp === undefined)
    {
        callback("NOT_FOUND")
        return
    }

    var tableName = process.env.TABLE_NAME;
    
    var item = {
        "text": event.text,
        "timestamp": event.timestamp
    }

    let params = {
        TableName: tableName,
        Item: item
    }

    dynamodb.put(params, function(err, data) {
            if (err) {
                console.log('ERROR: Dynamo failed: ' + err)
                callback('NOT_FOUND')
            } else {
                console.log('Dynamo Success: ' + JSON.stringify(data, null, '  '));
                
                callback(null, "Success")
            }
        });
}