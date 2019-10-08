"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var WSClient = require("websocket").client;
exports.newWebsocketClient = function (config) {
    return function () {
        return new WSClient(config);
    };
};
exports.newWebsocketClientImpl = function (config) { return function (e, s) { return s(new WSClient(config)); }; };
exports.connect = function (client) {
    return function (requestUrl) {
        return function (_a) {
            var protocols = _a.protocols, origin = _a.origin, headers = _a.headers, options = _a.options;
            return function () {
                client.connect(requestUrl, protocols, origin, headers, options);
            };
        };
    };
};
exports.connectImpl = function (client) { return function (reqUrl) { return function (_a) {
    var protocols = _a.protocols, origin = _a.origin, headers = _a.headers, options = _a.options;
    return function (e, s) {
        client.connect(reqUrl, protocols, origin, headers, options);
        s();
    };
}; }; };
exports.abort = function (client) {
    return function () {
        client.abort();
    };
};
exports.onConnect = function (client) {
    return function (callback) {
        return function () {
            client.on("connect", function (conn) {
                conn.birth = Date.now();
                callback(conn)();
            });
        };
    };
};
exports.onConnectImpl = function (client) { return function (cb) { return function (e, s) {
    client.on("connect", function (conn) {
        conn.birth = Date.now();
        cb(conn)();
    });
    s();
}; }; };
exports.onConnectFailed = function (client) {
    return function (callback) {
        return function () {
            client.on("connectFailed", function (errorDescription) {
                callback(errorDescription)();
            });
        };
    };
};
exports.onHttpResponse = function (client) {
    return function (callback) {
        return function () {
            client.on("httpResponse", function (response, webSocketClient) {
                callback(response)(webSocketClient)();
            });
        };
    };
};
