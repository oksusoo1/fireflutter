import * as admin from "firebase-admin";
export class Ref {
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

  /**
   * Returns user document reference.
   * @param uid uid
   * @returns user docuement reference
   */
  static userDoc(uid: string) {
    return this.users.child(uid);
  }
  /**
   * Alias of userDoc
   * @param uid uid
   * @returns user docuement reference
   */
  static user(uid: string) {
    return this.users.child(uid);
  }

  /**
   * Returns user point folder reference
   *
   * @param uid user uid
   * @returns Reference of user point folder
   */
  static point(uid: string): admin.database.Reference {
    return this.rdb.ref("point").child(uid);
  }
  static signInPoint(uid: string) {
    return this.point(uid).child("signIn");
  }
  static userPoint(uid: string) {
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
  static registerPoint(uid: string) {
    return this.point(uid).child("register");
  }

  static get messageTokens() {
    return this.rdb.ref("message-tokens");
  }

  static userSettings(uid: string) {
    return this.rdb.ref("user-settings").child(uid);
  }
  static userSetting(uid: string, setting: string) {
    return this.userSettings(uid).child(setting);
  }

  static userSettingTopic(uid: string) {
    return this.userSetting(uid, "topic");
  }
  // Point history folder for post point events.
  static postCreatePointHistory(uid: string) {
    return this.point(uid).child("postCreate");
  }

  // Point history folder for comment point events.
  static commentCreatePointHistory(uid: string) {
    return this.point(uid).child("commentCreate");
  }

  // Point history folder for extra point events.
  static extraPointHistory(uid: string) {
    return this.point(uid).child("extra");
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

  /**
   * Returns post reference
   * @param id post id
   * @return reference
   */
  static postDoc(id: string) {
    return this.postCol.doc(id);
  }
  /**
   * Returns comment reference
   * @param id comment id
   * @return reference
   */
  static commentDoc(id: string) {
    return this.commentCol.doc(id);
  }

  /**
   * Returns category referrence
   *
   * @param {*} id Category id
   * @return reference
   */
  static categoryDoc(id: string) {
    return this.categoryCol.doc(id);
  }
}
