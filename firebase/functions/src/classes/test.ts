import { UserCreate, UserModel } from "../interfaces/user.interface";
import { Ref } from "./ref";
import { ERROR_USER_EXISTS } from "../defines";
import { Meilisearch } from "../classes/meilisearch";
import { Utils } from "./utils";
import { CategoryDocument, PostCreateParams, PostDocument } from "../interfaces/forum.interface";

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

  /**
   * Create a category for test
   *
   * @param {*} data
   * @return reference of the cateogry
   */
  static async createCategory(data: CategoryDocument) {
    const id = data.id;
    // delete data.id; // call-by-reference. it will causes error after this method.
    data.timestamp = Utils.getTimestamp();
    await Ref.categoryDoc(id!).set(data, { merge: true });
    return Ref.categoryDoc(id!);
  }

  /**
 * Create a post for test
 *
 * @return reference
 *
 *
 * Create a post for a test
 *
 * @return reference
 *
 * @example
    const ref = await test.createPost({
      category: "test",
      post: {},
    });
    console.log((await ref.get()).data());
 * @example
 * await test.createPost({
    category: 'test',         // create a category
    post: {                   // post
        id: 'post_id_a',      // if post id exists, it sets. or create.
        title: 'post_title',
        uid: 'A',
    },
})
 */
  static async createPost(data: any) {
    // if data.category.id comes in, then it will prepare the category to be exist.
    if (data.category && data.category.id) {
      await this.createCategory(data.category);
      // console.log((await catDoc.get()).data());
      // console.log('category id; ', catDoc.id);
    }

    const postData: any = {
      category: data.category && data.category.id ? data.category.id : "test",
      title: data.post && data.post.title ? data.post.title : "create_post",
      uid: data.post && data.post.uid ? data.post.uid : "uid",
      createdAt: Utils.getTimestamp(),
      updatedAt: Utils.getTimestamp(),
    };

    if (data.post && data.post.id) {
      if (data.post.deleted && data.post.deleted === true) {
        postData.deleted = true;
      }

      await Ref.postDoc(data.post.id).set(postData, { merge: true });
      return Ref.postDoc(data.post.id);
    } else {
      return Ref.postCol.add(postData);
    }
  }
}
