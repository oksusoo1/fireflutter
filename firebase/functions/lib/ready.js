"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ready = void 0;
const user_1 = require("./classes/user");
async function ready(options, callback) {
    const req = options.req;
    const res = options.res;
    res.set("Access-Control-Allow-Origin", "*");
    if (req.method === "OPTIONS") {
        res.set("Access-Control-Allow-Methods", "GET");
        res.set("Access-Control-Allow-Methods", "POST");
        res.set("Access-Control-Allow-Methods", "DELETE");
        res.set("Access-Control-Allow-Methods", "PUT");
        res.set("Access-Control-Allow-Headers", "Content-Type");
        res.set("Access-Control-Max-Age", "3600");
        res.status(204).send("");
    }
    else {
        const data = Object.assign({}, req.body, req.query);
        if (options.auth) {
            const re = await user_1.User.authenticate(data);
            if (re) {
                res.status(200).send(re);
                return;
            }
        }
        /// Delete password if exists.
        if (data.password)
            delete data.password;
        callback(data).catch((e) => {
            res.status(200).send(e);
        });
    }
}
exports.ready = ready;
//# sourceMappingURL=ready.js.map