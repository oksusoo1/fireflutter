import { UserCreate, UserDocument } from "../interfaces/user.interface";
import { Ref } from "./ref";
import { ERROR_USER_EXISTS } from "../defines";
import { Meilisearch } from "../classes/meilisearch";
import { Utils } from "./utils";
import { CategoryDocument, CommentDocument, PostDocument } from "../interfaces/forum.interface";
import { Comment } from "./comment";

export class Test {
  static testCount = 0;

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
  static async createTestUser(uid: string, data?: UserDocument) {
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
  static async createTestUserAndGetDoc(uid: string, data?: UserDocument): Promise<UserDocument> {
    const ref = await this.createTestUser(uid, data);
    const snapshot = await ref.get();
    const val = snapshot.val();
    val.id = uid;
    return val;
  }

  static async createUser() {
    return this.createTestUserAndGetDoc("test-uid-" + ++this.testCount + Utils.getTimestamp());
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
   * Initializes meilisearch filters for a given index.
   *
   * @param index meilisearch index
   */
  static async initMeiliSearchIndexFilter(index: string, filters: string[]) {
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
  static async createCategory() {
    this.testCount++;
    const id = "test-cat-" + this.testCount + Utils.getTimestamp();
    // delete data.id; // call-by-reference. it will causes error after this method.
    const timestamp = Utils.getTimestamp();
    await Ref.categoryDoc(id).set({ timestamp: timestamp }, { merge: true });
    const snapshot = await Ref.categoryDoc(id).get();
    const data = snapshot.data() as CategoryDocument;
    data.id = id;
    return data;
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
    const ref = await test.createPost();
    console.log((await ref.get()).data());
 */
  static async createPost(): Promise<PostDocument> {
    const user = await this.createUser();
    const category = await this.createCategory();

    const postData: any = {
      category: category.id,
      title: "title-" + category.id,
      uid: user.id,
      createdAt: Utils.getTimestamp(),
      updatedAt: Utils.getTimestamp(),
    };
    // / create post

    const ref = await Ref.postCol.add(postData);

    const snapshot = await ref.get();
    const data = snapshot.data() as PostDocument;
    data.id = ref.id;
    return data;
  }

  static async createComment(data = {} as any): Promise<CommentDocument> {
    const post = this.createPost();
    data.postId = (await post!).id;
    return Comment.create(data);
  }
}
