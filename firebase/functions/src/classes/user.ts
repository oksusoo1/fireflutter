import { ERROR_AUTH_FAILED, ERROR_EMPTY_PASSWORD, ERROR_EMPTY_UID } from "../defines";
import { UserCreate, UserModel } from "../interfaces/user.interface";
import { Ref } from "./ref";
import { Utils } from "./utils";
import * as admin from "firebase-admin";

export class User {
  static get auth() {
    return admin.auth();
  }

  static async create(uid: string, data: UserCreate) {
    data.updatedAt = Utils.getTimestamp();
    data.registeredAt = Utils.getTimestamp();

    return Ref.userDoc(uid).set(data);
  }
  /**
   * Authenticates user with id and password.
   * @param data input data that has uid and password
   * @returns Error string on error. Empty string on success.
   */
  static async authenticate(data: { uid: string; password: string }): Promise<string> {
    if (!data.uid) {
      return ERROR_EMPTY_UID;
    } else if (!data.password) {
      return ERROR_EMPTY_PASSWORD;
    } else {
      const user = await this.get(data.uid);
      if (user?.password === data.password) return "";
      else return ERROR_AUTH_FAILED;
    }
  }

  /**
   * Returns user document as in User class
   * @param uid uid of user
   * @returns user document class
   */
  static async get(uid: string): Promise<UserModel | null> {
    const snapshot = await Ref.userDoc(uid).get();

    if (snapshot.exists()) {
      const val = snapshot.val();
      return UserModel.fromJson(val, uid);
    }

    return null;
  }

  static async isAdmin(context: any) {
    const doc = await Ref.adminDoc.get();
    const admins = doc.data();
    if (!context) return false;
    if (!context.auth) return false;
    if (!context.auth.uid) return false;
    if (!admins) return false;
    if (!admins[context.auth.uid]) return false;
    return true;
  }

  static async enableUser(data: any, context: any) {
    if (!this.isAdmin(context)) {
      return {
        code: "ERROR_YOU_ARE_NOT_ADMIN",
        message: "To manage user, you need to sign-in as an admin.",
      };
    }
    try {
      const user = await this.auth.updateUser(data.uid, { disabled: false });
      if (user.disabled == false) await Ref.users.child(data.uid).update({ disabled: false });
      return user;
    } catch (e) {
      return { code: "error", message: (e as Error).message };
    }
  }

  static async disableUser(data: any, context: any) {
    if (!this.isAdmin(context)) {
      return {
        code: "ERROR_YOU_ARE_NOT_ADMIN",
        message: "To manage user, you need to sign-in as an admin.",
      };
    }
    try {
      const user = await this.auth.updateUser(data.uid, { disabled: true });
      if (user.disabled == true) await Ref.users.child(data.uid).update({ disabled: true });
      return user;
    } catch (e) {
      return { code: "error", message: (e as Error).message };
    }
  }
}
