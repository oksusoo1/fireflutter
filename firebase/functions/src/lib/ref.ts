import * as admin from "firebase-admin";
export class Ref {
  static get rdb() {
    return admin.database();
  }
  static userPoint(uid: string) {
    return this.rdb.ref("point").child(uid);
  }
  static userPointSignIn(uid: string) {
    return this.userPoint(uid).child("signIn");
  }
}
