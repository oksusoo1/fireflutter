"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.User = void 0;
const defines_1 = require("../defines");
const ref_1 = require("./ref");
const utils_1 = require("./utils");
const admin = require("firebase-admin");
// import { GetUsersResult } from "firebase-admin/lib/auth/base-auth";
// import { ErrorCodeMessage } from "../interfaces/common.interface";
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
     * @returns Error string on error(not throwing as an exception). Empty string on success.
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
        if (!context)
            return false;
        if (context.empty)
            return false;
        if (!context.auth)
            return false;
        if (!context.auth.uid)
            return false;
        const doc = await ref_1.Ref.adminDoc.get();
        const admins = doc.data();
        if (!admins)
            return false;
        if (!admins[context.auth.uid])
            return false;
        return true;
    }
    static async enableUser(data, context) {
        if (!(await this.isAdmin(context))) {
            return {
                code: defines_1.ERROR_YOU_ARE_NOT_ADMIN,
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
                code: defines_1.ERROR_YOU_ARE_NOT_ADMIN,
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
    // https://firebase.google.com/docs/auth/admin/manage-users#bulk_retrieve_user_data
    static async adminUserSearch(data, context) {
        if (!(await this.isAdmin(context))) {
            return {
                code: defines_1.ERROR_YOU_ARE_NOT_ADMIN,
                message: "To manage user, you need to sign-in as an admin.",
            };
        }
        if (!data.email && !data.phoneNumber)
            return defines_1.ERROR_EMTPY_EMAIL_AND_PHONE_NUMBER;
        if (data.email && data.phoneNumber)
            return defines_1.ERROR_ONE_OF_EMAIL_AND_PHONE_NUMBER_MUST_BY_EMPTY;
        const req = [];
        req.push(data);
        console.log(req);
        try {
            const result = await this.auth.getUsers(req);
            // result.users.forEach((userRecord) => {
            //   console.log(userRecord);
            // });
            // // console.log("Unable to find users corresponding to these identifiers:");
            // result.notFound.forEach((userIdentifier) => {
            //   console.log(userIdentifier);
            // });
            return result;
        }
        catch (e) {
            return {
                code: "ERROR_USER_SEARCH",
                message: e.message,
            };
        }
    }
    /**
     *
     * ! warning. this is very week password, but it is difficult to guess.
     * ! You may add more properties like `phone number`, `email` to make the password more strong.
     *
     * @param doc user model
     * @returns password string
     */
    static generatePassword(doc) {
        return doc.id + "-" + doc.registeredAt + "-" + doc.updatedAt;
    }
}
exports.User = User;
//# sourceMappingURL=user.js.map