

export const wsConnEqImpl = a => b => a === b

export const wsConnOrdImpl = gt => eq => lt => a => b => {
    return a.birth > b.birth ? gt : ((a === b) ? eq : lt)
}
export const wsConnShowImpl = conn => `WebSocket connection to ${conn.remoteAddress} started at ${conn.birth}`