import { ERROR_AUTH_FAILED, ERROR_EMPTY_PASSWORD, ERROR_EMPTY_UID } from "../defines";
import { Ref } from "./ref";

export class User {
  /**
   * Authenticates user with id and password.
   * @param data input data that has uid and password
   * @returns Error string on error. Empty string on success.
   */
  static authenticate(data: { uid: string; password: string }): string {
    if (!data.uid) {
      return ERROR_EMPTY_UID;
    } else if (!data.password) {
      return ERROR_EMPTY_PASSWORD;
    } else {
      const ref = Ref.userDoc(data.uid);

      return ERROR_AUTH_FAILED;
    }
  }
}
