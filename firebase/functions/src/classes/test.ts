import { UserCreate, UserModel } from "../interfaces/user.interface";
import { Ref } from "./ref";
import { ERROR_USER_EXISTS } from "../defines";
import { Meilisearch } from "../classes/meilisearch";

export class Test {
  /**
   * Create a user for test
   *
   * It creates a user document under /users/<uid> with user data and returns user ref.
   *
   * @param {*} uid
   * @return - reference of newly created user's document.
   *
   * @example create a user.
   * test.createTestUser(userA).then((v) => console.log(v));
   */
  static async createTestUser(uid: string, data?: UserModel) {
    // check if the user of uid exists, then return null

    const ref = await Ref.user(uid).get();
    if (ref.exists()) throw ERROR_USER_EXISTS;

    const timestamp = new Date().getTime();

    const userData: UserCreate = {
      nickname: "testUser" + timestamp,
      firstName: "firstName" + timestamp,
      lastName: "lastName" + timestamp,
      registeredAt: timestamp,
    };

    if (data !== null) {
      Object.assign(userData, data);
    }

    await Ref.user(uid).set(userData);
    return Ref.rdb.ref("users").child(uid);
  }

  /**
   * Creates a use and returns the document data.
   * @param uid uid
   * @param data data
   * @returns document object
   */
  static async createTestUserAndGetDoc(uid: string, data?: UserModel): Promise<UserModel> {
    const ref = await this.createTestUser(uid, data);
    const snapshot = await ref.get();
    return snapshot.val();
  }

  /**
   * delets a test user from realtime database.
   *
   * @param {*} uid
   * @return - reference.
   */
  static async deleteTestUser(uid: string) {
    return Ref.rdb.ref("users").child(uid).remove();
  }

  /**
   * Initializes index search filter.
   *
   * @param index meilisearch index
   */
  static async initIndexFilter(index: string, filters: string[]) {
    const indexFilters = await Meilisearch.client.index(index).getFilterableAttributes();

    if (filters?.length) {
      filters.forEach((f) => {
        if (!indexFilters.includes(f)) {
          indexFilters.push(f);
        }
      });
      await Meilisearch.client.index(index).updateFilterableAttributes(indexFilters);
    }
  }
}
