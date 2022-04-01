import * as admin from "firebase-admin";
export class Ref {
  static get db() {
    const db = admin.firestore();
    return db;
  }

  static get rdb() {
    return admin.database();
  }
  static get users() {
    return this.rdb.ref("users");
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
  static pointSignIn(uid: string) {
    return this.point(uid).child("signIn");
  }
  static userPoint(uid: string) {
    return this.point(uid).child("point");
  }

  /**
   * Returns the reference of point register of the user of uid
   *
   * Use this function to get user's register point document.
   *
   * @param {*} uid uid
   */
  static pointRegister(uid: string) {
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

  // post create point folder of the user
  static pointPostCreate(uid: string) {
    return this.point(uid).child("postCreate");
  }

  // comment create point folder of the user
  static pointCommentCreate(uid: string) {
    return this.point(uid).child("commentCreate");
  }

  static get postCol() {
    return this.db.collection("posts");
  }

  static get commentCol() {
    return this.db.collection("comments");
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
}
