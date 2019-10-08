export const closeDescription = function (conn) {
  return conn.closeDescription;
}

export const closeReasonCode = function (conn) {
  return conn.closeReasonCode;
}

export const protocol = function (conn) {
  return conn.protocol;
}

export const remoteAddress = function (conn) {
  return conn.remoteAddress;
}

export const webSocketVersion = function (conn) {
  return conn.webSocketVersion;
}

export const connected = function (conn) {
  return conn.connected;
}

export const closeWithReason = function (conn) {
  return function (reasonCode) {
    return function (description) {
      return function () {
        conn.close(reasonCode, description);
      }
    }
  }
}

export const close = function (conn) {
  return function () {
    conn.close();
  }
}

export const closeImpl = conn => (e, s) => {
  conn.close();
  s();
}

export const drop = function (conn) {
  return function (reasonCode) {
    return function (description) {
      return function () {
        conn.drop(reasonCode, description);
      }
    }
  }
}

export const sendUTF = function (conn) {
  return function (msg) {
    return function () {
      conn.sendUTF(msg);
    }
  }
}

export const sendUTFImpl = conn => msg => (e, s) => {
  conn.sendUTF(msg)
  s();
}

export const sendBytes = function (conn) {
  return function (buffer) {
    return function () {
      conn.sendBytes(buffer);
    }
  }
}

export const sendBytesImpl = conn => buffer => (e, s) => { conn.sendBytes(buffer); s(); }

export const ping = function (conn) {
  return function (buffer) {
    return function () {
      conn.ping(buffer);
    }
  }
}

export const pong = function (conn) {
  return function (buffer) {
    return function () {
      conn.pong(buffer);
    }
  }
}

export const sendFrame = function (conn) {
  return function (frame) {
    return function () {
      conn.sendFrame(frame);
    }
  }
}

export const onMsgImpl = Left => Right => conn => effCb => async (e, s) => {
  conn.on("message", async msg => {
    effCb((msg.type === "utf8" ? Left : Right)(msg))()
  })
}

export const onMessageImpl = function (Left) {
  return function (Right) {
    return function (conn) {
      return function (callback) {
        return function () {
          conn.on("message", function (msg) {
            if (msg.type == "utf8") {
              callback(Left(msg))();
              return;
            }
            callback(Right(msg))();
          })
        }
      }
    }
  }
}

export const onFrame = function (conn) {
  return function (callback) {
    return function () {
      conn.on("frame", function (frame) {
        callback(frame)();
      })
    }
  }
}

export const onClose = function (conn) {
  return function (callback) {
    return function () {
      conn.on("close", function(reasonCode, description) {
        callback(reasonCode)(description)();
      })
    }
  }
}

export const onCloseImpl = conn => cb => (e, s) => {
  conn.on("close", (reasonCode, desc) => {
    cb(reasonCode)(desc)()
  })
  s()
}

export const onError = function (conn) {
  return function (callback) {
    return function () {
      conn.on("error", function (err) {
        callback(err)();
      })
    }
  }
}

export const onPing = function (conn) {
  return function (callback) {
    return function () {
      conn.on("ping", function(cancel, data) {
        callback(data)(cancel)();
      })
    }
  }
}

export const onPong = function (conn) {
  return function (callback) {
    return function () {
      conn.on("pong", function (data) {
        callback(data)();
      })
    }
  }
}