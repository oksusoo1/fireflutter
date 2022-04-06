"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.User = void 0;
const defines_1 = require("../defines");
const ref_1 = require("./ref");
const utils_1 = require("./utils");
const admin = require("firebase-admin");
class User {
    static get auth() {
        return admin.auth();
    }
    static async create(uid, data) {
        data.updatedAt = utils_1.Utils.getTimestamp();
        data.registeredAt = utils_1.Utils.getTimestamp();
        return ref_1.Ref.userDoc(uid).set(data);
    }
    /**
     * Authenticates user with id and password.
     * @param data input data that has uid and password
     * @returns Error string on error. Empty string on success.
     */
    static async authenticate(data) {
        if (!data.uid) {
            return defines_1.ERROR_EMPTY_UID;
        }
        else if (!data.password) {
            return defines_1.ERROR_EMPTY_PASSWORD;
        }
        else {
            const user = await this.get(data.uid);
            if (user === null) {
                return defines_1.ERROR_USER_NOT_FOUND;
            }
            const password = this.generatePassword(user);
            if (password === data.password)
                return "";
            else
                return defines_1.ERROR_WRONG_PASSWORD;
        }
    }
    /**
     * Returns user document as in User class
     * @param uid uid of user
     * @returns user document or empty map.
     */
    static async get(uid) {
        const snapshot = await ref_1.Ref.userDoc(uid).get();
        if (snapshot.exists()) {
            const val = snapshot.val();
            val.id = uid;
            return val;
        }
        return null;
    }
    static async isAdmin(context) {
        const doc = await ref_1.Ref.adminDoc.get();
        const admins = doc.data();
        if (!context)
            return false;
        if (context.empty)
            return false;
        if (!context.auth)
            return false;
        if (!context.auth.uid)
            return false;
        if (!admins)
            return false;
        if (!admins[context.auth.uid])
            return false;
        return true;
    }
    static async enableUser(data, context) {
        if (!(await this.isAdmin(context))) {
            return {
                code: "ERROR_YOU_ARE_NOT_ADMIN",
                message: "To manage user, you need to sign-in as an admin.",
            };
        }
        try {
            const user = await this.auth.updateUser(data.uid, { disabled: false });
            if (user.disabled == false)
                await ref_1.Ref.users.child(data.uid).update({ disabled: false });
            return user;
        }
        catch (e) {
            return { code: "error", message: e.message };
        }
    }
    static async disableUser(data, context) {
        if (!(await this.isAdmin(context))) {
            return {
                code: "ERROR_YOU_ARE_NOT_ADMIN",
                message: "To manage user, you need to sign-in as an admin.",
            };
        }
        try {
            const user = await this.auth.updateUser(data.uid, { disabled: true });
            if (user.disabled == true)
                await ref_1.Ref.users.child(data.uid).update({ disabled: true });
            return user;
        }
        catch (e) {
            return { code: "error", message: e.message };
        }
    }
    /**
     *
     * ! warning. this is very week password, but it is difficult to guess.
     *
     * @param doc user model
     * @returns password string
     */
    static generatePassword(doc) {
        var _a;
        return doc.id + "-" + doc.registeredAt + "-" + doc.updatedAt + "-" + ((_a = doc.point) !== null && _a !== void 0 ? _a : 0);
    }
}
exports.User = User;
//# sourceMappingURL=user.js.map