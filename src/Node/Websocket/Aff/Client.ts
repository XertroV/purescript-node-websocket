"use strict";

var WSClient = require("websocket").client;

exports.newWebsocketClient = function (config) {
  return function () {
    return new WSClient(config);
  }
}

export const newWebsocketClientImpl = config => (e, s) => s(new WSClient(config));

exports.connect = function (client) {
  return function (requestUrl) {
    return ({protocols, origin, headers, options}) => {
      return function () {
        client.connect(requestUrl, protocols, origin, headers, options);
      }
    }
  }
}

export const connectImpl = client => reqUrl => ({protocols, origin, headers, options}) => (e, s) => {
  client.connect(reqUrl, protocols, origin, headers, options);
  s();
}

exports.abort = function (client) {
  return function () {
    client.abort();
  }
}

exports.onConnect = function (client) {
  return function (callback) {
    return function () {
      client.on("connect", function (conn) {
        conn.birth = Date.now()
        callback(conn)();
      })
    }
  }
}

export const onConnectImpl = client => cb => (e, s) => {
  client.on("connect", conn => {
    conn.birth = Date.now();
    cb(conn)();
  })
  s();
}

exports.onConnectFailed = function (client) {
  return function (callback) {
    return function () {
      client.on("connectFailed", function (errorDescription) {
        callback(errorDescription)();
      })
    }
  }
}

exports.onHttpResponse = function (client) {
  return function (callback) {
    return function () {
      client.on("httpResponse", function (response, webSocketClient) {
        callback(response)(webSocketClient)();
      })
    }
  }
}