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

  // post create point folder of the user
  static pointPostCreate(uid: string) {
    return this.point(uid).child("postCreate");
  }

  // comment create point folder of the user
  static pointCommentCreate(uid: string) {
    return this.point(uid).child("commentCreate");
  }

  /**
   * Returns post reference
   * @param id post id
   * @return reference
   */
  static postDoc(id: string) {
    return this.db.collection("posts").doc(id);
  }
}
