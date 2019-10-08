"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.wsConnEqImpl = function (a) { return function (b) { return a === b; }; };
exports.wsConnOrdImpl = function (gt) { return function (eq) { return function (lt) { return function (a) { return function (b) {
    return a.birth > b.birth ? gt : ((a === b) ? eq : lt);
}; }; }; }; };
exports.wsConnShowImpl = function (conn) { return "WebSocket connection to " + conn.remoteAddress + " started at " + conn.birth; };
