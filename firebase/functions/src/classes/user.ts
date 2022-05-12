import {
  ERROR_WRONG_PASSWORD,
  ERROR_EMPTY_PASSWORD,
  ERROR_EMPTY_UID,
  ERROR_EMTPY_EMAIL_AND_PHONE_NUMBER,
  ERROR_ONE_OF_EMAIL_AND_PHONE_NUMBER_MUST_BY_EMPTY,
  ERROR_YOU_ARE_NOT_ADMIN,
  ERROR_USER_NOT_FOUND,
  ERROR_USER_AUTH_NOT_FOUND,
  ERROR_USER_DOC_NOT_FOUND,
  ERROR_SIGNIN_TOKEN_NOT_EXISTS,
} from "../defines";
import { UserCreate, UserDocument } from "../interfaces/user.interface";
import { Ref } from "./ref";
import { Utils } from "./utils";
import * as admin from "firebase-admin";
// import { GetUsersResult } from "firebase-admin/lib/auth/base-auth";
// import { ErrorCodeMessage } from "../interfaces/common.interface";

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
   * @returns Error string on error(not throwing as an exception). Empty string on success.
   */
  static async authenticate(data: { uid: string; password: string }): Promise<string> {
    if (!data.uid) {
      return ERROR_EMPTY_UID;
    } else if (!data.password) {
      return ERROR_EMPTY_PASSWORD;
    } else {
      const user = await this.get(data.uid);
      if (user === null) {
        return ERROR_USER_NOT_FOUND;
      }
      const password = this.generatePassword(user);
      if (password === data.password) return "";
      else return ERROR_WRONG_PASSWORD;
    }
  }

  /**
   * Returns user document as in User class
   * @param uid uid of user
   * @returns user document or empty map.
   */
  static async get(uid: string): Promise<UserDocument | null> {
    const snapshot = await Ref.userDoc(uid).get();

    if (snapshot.exists()) {
      const val = snapshot.val() as UserDocument;
      val.id = uid;
      return val;
    }

    return null;
  }

  /**
   *
   * @param uid
   */
  static async isAdmin(uid: string) {
    if (!uid) return false;

    const doc = await Ref.adminDoc.get();
    const admins = doc.data();
    if (!admins) return false;
    if (!admins[uid]) return false;
    return true;
  }

  static async enableUser(data: any, context: any) {
    if (!(await this.isAdmin(context))) {
      return {
        code: ERROR_YOU_ARE_NOT_ADMIN,
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

  static async disableUser(
    data: any,
    context: any
  ): Promise<
    | admin.auth.UserRecord
    | {
        code: string;
        message: string;
      }
  > {
    if (!(await this.isAdmin(context))) {
      return {
        code: ERROR_YOU_ARE_NOT_ADMIN,
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

  // https://firebase.google.com/docs/auth/admin/manage-users#bulk_retrieve_user_data
  static async adminUserSearch(data: { email?: string; phoneNumber?: string }, context: any) {
    if (!(await this.isAdmin(context))) {
      return {
        code: ERROR_YOU_ARE_NOT_ADMIN,
        message: "To manage user, you need to sign-in as an admin.",
      };
    }

    if (!data.email && !data.phoneNumber) return ERROR_EMTPY_EMAIL_AND_PHONE_NUMBER;
    if (data.email && data.phoneNumber) return ERROR_ONE_OF_EMAIL_AND_PHONE_NUMBER_MUST_BY_EMPTY;

    const req: Array<any> = [];

    req.push(data);

    // console.log(req);
    try {
      const result = await this.auth.getUsers(req);
      // result.users.forEach((userRecord) => {
      //   console.log(userRecord);
      // });

      // // console.log("Unable to find users corresponding to these identifiers:");
      // result.notFound.forEach((userIdentifier) => {
      //   console.log(userIdentifier);
      // });
      if (result.users.length == 0) return ERROR_USER_AUTH_NOT_FOUND;
      const user = result.users[0];
      const userDoc = await this.get(user.uid);
      if (!userDoc) return ERROR_USER_DOC_NOT_FOUND;
      return user;
    } catch (e) {
      return {
        code: "ERROR_USER_SEARCH",
        message: (e as Error).message,
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
  static generatePassword(doc: UserDocument): string {
    return doc.id + "-" + doc.registeredAt;
  }

  static async getSignInToken(data: { id: string }): Promise<UserDocument | null> {
    const snapshot = await Ref.signInTokenDoc(data.id).get();

    if (snapshot.exists()) {
      const val: { uid: string } = snapshot.val();
      await Ref.signInTokenDoc(data.id).remove();
      return await User.get(val.uid);
    }

    throw ERROR_SIGNIN_TOKEN_NOT_EXISTS;
  }
}
