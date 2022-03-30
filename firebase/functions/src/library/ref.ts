import * as admin from "firebase-admin";
export class Ref {
  static get rdb() {
    return admin.database();
  }
  static get users() {
    return this.rdb.ref("users");
  }
  static user(uid: string) {
    return this.users.child(uid);
  }
  static userPointFolder(uid: string) {
    return this.rdb.ref("point").child(uid);
  }
  static userPointSignIn(uid: string) {
    return this.userPointFolder(uid).child("signIn");
  }
  static userPoint(uid: string) {
    return this.userPointFolder(uid).child("point");
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
}
