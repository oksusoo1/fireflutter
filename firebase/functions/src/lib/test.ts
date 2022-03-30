import { Ref } from "./ref";
export class Test {
  /**
   * Create a user for test
   *
   * It creates a user document under /users/<uid> with user data and returns user ref.
   *
   * @param {*} uid
   * @returns - reference.
   *
   * @example create a user.
   * test.createTestUser(userA).then((v) => console.log(v));
   */
  static async createTestUser(uid: string, data?: any) {
    const timestamp = new Date().getTime();

    let userData = {
      nickname: "testUser" + timestamp,
      firstName: "firstName" + timestamp,
      lastName: "lastName" + timestamp,
      registeredAt: timestamp,
    };
    console.log(userData);
    if (data !== null) {
      userData = data;
    }
    await Ref.rdb.ref("users").child(uid).set(userData);
    return Ref.rdb.ref("users").child(uid);
  }

  /**
   * delets a test user from realtime database.
   *
   * @param {*} uid
   * @returns - reference.
   */
  static async deleteTestUser(uid: string) {
    return Ref.rdb.ref("users").child(uid).remove();
  }
}
