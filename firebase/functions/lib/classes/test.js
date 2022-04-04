"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Test = void 0;
const ref_1 = require("./ref");
const defines_1 = require("../defines");
const meilisearch_1 = require("../classes/meilisearch");
const utils_1 = require("./utils");
class Test {
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
    static async createTestUser(uid, data) {
        // check if the user of uid exists, then return null
        const ref = await ref_1.Ref.user(uid).get();
        if (ref.exists())
            throw defines_1.ERROR_USER_EXISTS;
        const timestamp = new Date().getTime();
        const userData = {
            nickname: "testUser" + timestamp,
            firstName: "firstName" + timestamp,
            lastName: "lastName" + timestamp,
            registeredAt: timestamp,
        };
        if (data !== null) {
            Object.assign(userData, data);
        }
        await ref_1.Ref.user(uid).set(userData);
        return ref_1.Ref.rdb.ref("users").child(uid);
    }
    /**
     * Creates a use and returns the document data.
     * @param uid uid
     * @param data data
     * @returns document object
     */
    static async createTestUserAndGetDoc(uid, data) {
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
    static async deleteTestUser(uid) {
        return ref_1.Ref.rdb.ref("users").child(uid).remove();
    }
    /**
     * Initializes meilisearch filters for a given index.
     *
     * @param index meilisearch index
     */
    static async initMeiliSearchIndexFilter(index, filters) {
        const indexFilters = await meilisearch_1.Meilisearch.client.index(index).getFilterableAttributes();
        if (filters === null || filters === void 0 ? void 0 : filters.length) {
            filters.forEach((f) => {
                if (!indexFilters.includes(f)) {
                    indexFilters.push(f);
                }
            });
            await meilisearch_1.Meilisearch.client.index(index).updateFilterableAttributes(indexFilters);
        }
    }
    /**
     * Create a category for test
     *
     * @param {*} data
     * @return reference of the cateogry
     */
    static async createCategory(data) {
        const id = data.id;
        // delete data.id; // call-by-reference. it will causes error after this method.
        data.timestamp = utils_1.Utils.getTimestamp();
        await ref_1.Ref.categoryDoc(id).set(data, { merge: true });
        return ref_1.Ref.categoryDoc(id);
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
    static async createPost(data) {
        // if data.category.id comes in, then it will prepare the category to be exist.
        if (data.category && data.category.id) {
            await this.createCategory(data.category);
            // console.log((await catDoc.get()).data());
            // console.log('category id; ', catDoc.id);
        }
        // const postData: any = {
        //   category: data.category && data.category.id ? data.category.id : "test",
        //   title: data.post && data.post.title ? data.post.title : "create_post",
        //   uid: data.post && data.post.uid ? data.post.uid : "uid",
        //   createdAt: Utils.getTimestamp(),
        //   updatedAt: Utils.getTimestamp(),
        // };
        // / create post
        // if (data.post && data.post.id) {
        //   if (data.post.deleted && data.post.deleted === true) {
        //     postData.deleted = true;
        //   }
        //   await Ref.postDoc(data.post.id).set(postData, { merge: true });
        //   return Ref.postDoc(data.post.id);
        // } else {
        //   return Ref.postCol.add(postData);
        // }
    }
}
exports.Test = Test;
//# sourceMappingURL=test.js.map