import { ERROR_AUTH_FAILED, ERROR_EMPTY_PASSWORD, ERROR_EMPTY_UID } from "../defines";
import { UserCreate, UserModel } from "../interfaces/user.interface";
import { Ref } from "./ref";
import { Utils } from "./utils";

export class User {
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
}
