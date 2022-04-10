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
        const val = snapshot.val();
        val.id = uid;
        return val;
    }
    static async createUser() {
        return this.createTestUserAndGetDoc("test-uid-" + ++this.testCount + utils_1.Utils.getTimestamp());
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
    static async createCategory() {
        this.testCount++;
        const id = "test-cat-" + this.testCount + utils_1.Utils.getTimestamp();
        // delete data.id; // call-by-reference. it will causes error after this method.
        const timestamp = utils_1.Utils.getTimestamp();
        await ref_1.Ref.categoryDoc(id).set({ timestamp: timestamp }, { merge: true });
        const snapshot = await ref_1.Ref.categoryDoc(id).get();
        const data = snapshot.data();
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
    static async createPost() {
        const user = await this.createUser();
        const category = await this.createCategory();
        const postData = {
            category: category.id,
            title: "title-" + category.id,
            uid: user.id,
            createdAt: utils_1.Utils.getTimestamp(),
            updatedAt: utils_1.Utils.getTimestamp(),
        };
        // / create post
        const ref = await ref_1.Ref.postCol.add(postData);
        const snapshot = await ref.get();
        const data = snapshot.data();
        data.id = ref.id;
        return data;
    }
}
exports.Test = Test;
Test.testCount = 0;
//# sourceMappingURL=test.js.map