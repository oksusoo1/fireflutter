"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserModel = void 0;
/**
 *
 */
class UserModel {
    constructor() {
        this.id = "";
        this.isAdmin = false;
        this.lastName = "";
        this.firstName = "";
        this.middleName = "";
        this.nickname = "";
        this.registeredAt = 0;
        this.updatedAt = 0;
        this.point = 0;
        this.photoUrl = "";
        this.gender = "";
        this.birthday = 0;
        this.password = "";
    }
    static fromJson(doc, id) {
        var _a, _b, _c, _d, _e, _f, _g, _h, _j, _k, _l;
        const o = new UserModel();
        o.id = id;
        o.isAdmin = (_a = doc.isAdmin) !== null && _a !== void 0 ? _a : false;
        o.lastName = (_b = doc.lastName) !== null && _b !== void 0 ? _b : "";
        o.firstName = (_c = doc.firstName) !== null && _c !== void 0 ? _c : "";
        o.middleName = (_d = doc.middleName) !== null && _d !== void 0 ? _d : "";
        o.nickname = (_e = doc.nickname) !== null && _e !== void 0 ? _e : "";
        o.photoUrl = (_f = doc.photoUrl) !== null && _f !== void 0 ? _f : "";
        o.gender = (_g = doc.gender) !== null && _g !== void 0 ? _g : "";
        o.birthday = (_h = doc.birthday) !== null && _h !== void 0 ? _h : 0;
        o.registeredAt = (_j = doc.registeredAt) !== null && _j !== void 0 ? _j : 0;
        o.updatedAt = (_k = doc.updatedAt) !== null && _k !== void 0 ? _k : 0;
        o.point = (_l = doc.point) !== null && _l !== void 0 ? _l : 0;
        o.password = this.generatePassword(o);
        return o;
    }
    /**
     *
     * ! warning. this is very week password, but it is difficult to guess.
     *
     * @param doc user model
     * @returns password string
     */
    static generatePassword(doc) {
        return doc.id + "-" + doc.registeredAt + "-" + doc.updatedAt + "-" + doc.point;
    }
}
exports.UserModel = UserModel;
//# sourceMappingURL=user.interface.js.map