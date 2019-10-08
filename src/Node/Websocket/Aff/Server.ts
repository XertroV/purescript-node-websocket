"use strict";

var WSServer = require("websocket").server;

exports.newWebsocketServer = function (config) {
  return function () {
    return new WSServer(config);
  }
}

export const newWebsocketServerImpl = config => (e, s) => s(new WSServer(config));

exports.onRequest = function (server) {
  return function (callback) {
    return function () {
      server.on("request", function (req) {
        callback(req)();
      })
    }
  }
}

export const onRequestImpl = server => callback => (e, s) => {
    server.on("request", req => {
        callback(req)();
    })
    s();
}

exports.onConnect = function (server) {
  return function (callback) {
    return function () {
      server.on("connect", function (conn) {
        conn.birth = Date.now()
        callback(conn)();
      })
    }
  }
}

exports.onClose = function (server) {
  return function (callback) {
    return function () {
      server.on("close", function (conn, reason, description) {
        callback(conn)(reason)(description)();
      })
    }
  }
}

export const onCloseImpl = server => cb => (e, s) => {
    server.on("close", (conn, reason, desc) => {
        cb(conn)(reason)(desc)();
    })
    s();
}

exports.shutdown = server => () => server.shutDown()
export const shutdownImpl = server => (e, s) => { server.shutDown(); s() }