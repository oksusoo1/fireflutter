"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Ref = void 0;
const admin = require("firebase-admin");
class Ref {
    static get db() {
        return admin.firestore();
    }
    static get rdb() {
        return admin.database();
    }
    static get users() {
        return this.rdb.ref("users");
    }
    static get adminDoc() {
        return this.db.collection("settings").doc("admins");
    }
    static get postCol() {
        return this.db.collection("posts");
    }
    static get commentCol() {
        return this.db.collection("comments");
    }
    static get categoryCol() {
        return this.db.collection("categories");
    }
    static get reportCol() {
        return this.db.collection("reports");
    }
    static reportDoc(id) {
        return this.reportCol.doc(id);
    }
    static get signInToken() {
        return this.rdb.ref("sign-in-token");
    }
    static signInTokenDoc(id) {
        return this.signInToken.child(id);
    }
    /**
     * Returns user document reference.
     * @param uid uid
     * @returns user docuement reference
     */
    static userDoc(uid) {
        return this.users.child(uid);
    }
    /**
     * Alias of userDoc
     * @param uid uid
     * @returns user docuement reference
     */
    static user(uid) {
        return this.users.child(uid);
    }
    /**
     * Returns post reference
     * @param id post id
     * @return reference
     */
    static postDoc(id) {
        return this.postCol.doc(id);
    }
    /**
     * Returns comment reference
     * @param id comment id
     * @return reference
     */
    static commentDoc(id) {
        return this.commentCol.doc(id);
    }
    /**
     * Returns category referrence
     *
     * @param {*} id Category id
     * @return reference
     */
    static categoryDoc(id) {
        return this.categoryCol.doc(id);
    }
    /**
     * Returns user point folder reference
     *
     * @param uid user uid
     * @returns Reference of user point folder
     */
    static point(uid) {
        return this.rdb.ref("point").child(uid);
    }
    static signInPoint(uid) {
        return this.point(uid).child("signIn");
    }
    static userPoint(uid) {
        return this.point(uid).child("point");
    }
    /**
     * Returns the reference of register bonus point document of the user of uid
     *
     * Use this function to get user's register point document where the register
     * bonus point is(will be) saved.
     *
     * @param {*} uid uid
     */
    static registerPoint(uid) {
        return this.point(uid).child("register");
    }
    static userSettingForumTopics(uid) {
        return this.userSettingTopic(uid).child("forum");
    }
    static userSettings(uid) {
        return this.rdb.ref("user-settings").child(uid);
    }
    static userSetting(uid, setting) {
        return this.userSettings(uid).child(setting);
    }
    static userSettingTopic(uid) {
        return this.userSetting(uid, "topic");
    }
    // Point history folder for post point events.
    static postCreatePointHistory(uid) {
        return this.point(uid).child("postCreate");
    }
    // Point history folder for comment point events.
    static commentCreatePointHistory(uid) {
        return this.point(uid).child("commentCreate");
    }
    // Point history folder for extra point events.
    static extraPointHistory(uid) {
        return this.point(uid).child("extra");
    }
    /** ****************************** MESSAGING References ****************************/
    static get messageTokens() {
        return this.rdb.ref("message-tokens");
    }
    static token(id) {
        return this.messageTokens.child(id);
    }
}
exports.Ref = Ref;
//# sourceMappingURL=ref.js.map