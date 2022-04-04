"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.User = void 0;
const defines_1 = require("../defines");
const user_interface_1 = require("../interfaces/user.interface");
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
            if ((user === null || user === void 0 ? void 0 : user.password) === data.password)
                return "";
            else
                return defines_1.ERROR_AUTH_FAILED;
        }
    }
    /**
     * Returns user document as in User class
     * @param uid uid of user
     * @returns user document class
     */
    static async get(uid) {
        const snapshot = await ref_1.Ref.userDoc(uid).get();
        if (snapshot.exists()) {
            const val = snapshot.val();
            return user_interface_1.UserModel.fromJson(val, uid);
        }
        return null;
    }
    static async isAdmin(context) {
        const doc = await ref_1.Ref.adminDoc.get();
        const admins = doc.data();
        if (!context)
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
        if (!this.isAdmin(context)) {
            return {
                code: "ERROR_YOU_ARE_NOT_ADMIN",
                message: "To manage user, you need to sign-in as an admin.",
            };
        }
        try {
            const user = await this.auth.updateUser(data.uid, { disabled: false });
            if (user.disabled == false)
                await ref_1.Ref.users.child(data.uid).update({ disabled: false });
            return { code: "success", result: user };
        }
        catch (e) {
            return { code: "error", message: e };
        }
    }
    static async disableUser(data, context) {
        if (!this.isAdmin(context)) {
            return {
                code: "ERROR_YOU_ARE_NOT_ADMIN",
                message: "To manage user, you need to sign-in as an admin.",
            };
        }
        try {
            const user = await this.auth.updateUser(data.uid, { disabled: true });
            if (user.disabled == true)
                await ref_1.Ref.users.child(data.uid).update({ disabled: true });
            return { code: "success", result: user };
        }
        catch (e) {
            return { code: "error", message: e };
        }
    }
}
exports.User = User;
//# sourceMappingURL=user.js.map