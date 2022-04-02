"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.User = void 0;
const defines_1 = require("../defines");
const user_interface_1 = require("../interfaces/user.interface");
const ref_1 = require("./ref");
const utils_1 = require("./utils");
class User {
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
}
exports.User = User;
//# sourceMappingURL=user.js.map