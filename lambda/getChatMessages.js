"use strict";

console.log('Loading event');
let AWS = require('aws-sdk');
let dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = function(event, context, callback) {
    console.log("Request received:\n", JSON.stringify(event));
    console.log("Context received:\n", JSON.stringify(context));

    let tableName = process.env.TABLE_NAME;

    let item = {
        "text": event.text,
        "timestamp": event.timestamp
    };

    let params = {
        TableName: tableName
    };

    function onScan(err, data) {
        if(err) {
            console.log('ERROR: Dynamo failed: ' + JSON.stringify(err));
            callback('bad');
            return null
        }
        else {
            let items = [];

            console.log(JSON.stringify(data));

            //add each item to the list of items
            data.Items.forEach((item) => {
                items.push(item)
            });

            //if there's more values, recursively call this function to add them
            if(typeof data.LastEvaluatedKey != "undefined") {
                console.log("Getting more");
                params.ExclusiveStartKey = data.LastEvaluatedKey;
                dynamodb.scan(params, onScan);
            }

            callback(null, items)
        }
    }

    dynamodb.scan(params, onScan)
};