const admin = require("firebase-admin");

const utils = require("./utils");

// get firestore
const db = admin.firestore();

// get real time database
const rdb = admin.database();

const ref = require("./reference");

/**
 * Create a category for test
 *
 * @param {*} data
 * @return reference of the cateogry
 */
async function createCategory(data) {
  const id = data.id;
  // delete data.id; // call-by-reference. it will causes error after this method.
  data.timestamp = utils.getTimestamp();
  await ref.categoryDoc(id).set(data, {merge: true});
  return ref.categoryDoc(id);
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
async function createPost(data) {
  // if data.category.id comes in, then it will prepare the category to be exist.
  if (data.category && data.category.id) {
    await createCategory(data.category);
    // console.log((await catDoc.get()).data());
    // console.log('category id; ', catDoc.id);
  }

  const postData = {
    category: data.category && data.category.id ? data.category.id : "test",
    title: data.post && data.post.title ? data.post.title : "create_post",
    uid: data.post && data.post.uid ? data.post.uid : "uid",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  if (data.post && data.post.id) {
    if (data.post.deleted && data.post.deleted === true) {
      postData.deleted = true;
    }

    await ref.postDoc(data.post.id).set(postData, {merge: true});
    return ref.postDoc(data.post.id);
  } else {
    return db.collection("posts").add(postData);
  }
}

/**
   * Create a comment for a test
   *
   * @return reference
   *
   *
   * await lib.createComment({
      category: 'test',         // create a category
      post: {                   // post
          id: 'post_id_a',      // if post id exists, it sets. or create.
          title: 'post_title',
          uid: 'A',
      },
      comment: {
          id: 'comment_id_a',         // if comment id exists, it sets. or create.
          content: 'comment_content',
          uid: 'B',
      }
    });

    *
    * since
    *   - there is no category, category is not created.
    *   - there is no post, post is not created.
    *
    await lib.createComment({
      comment: {
          id: 'comment_id_a',         // if comment id exists, it sets. or create.
          postId: 'post_id_a',
          parentId: 'comemnt_id_a',
          content: 'comment_content',
          uid: 'B',
        }
    });
   */
async function createComment(data) {
  if (data.category && data.category.id) {
    await createCategory(data.category);
  }

  let commentData;
  // If there is no postId in data, then create one.
  if (data.post) {
    const ref = await createPost(data);

    commentData = {
      postId: ref.id,
      parentId: ref.id,
      content: data.comment.content,
      uid: data.comment.uid ? data.comment.uid : "uid",
    };
  } else {
    commentData = {
      postId: data.comment.postId,
      parentId: data.comment.parentId,
      content: data.comment.content ? data.comment.content : "",
      uid: data.comment.uid ? data.comment.uid : "uid",
    };
  }
  // if no comment id, then create one
  if (!data.comment.id) {
    return db.collection("comments").add(commentData);
  } else {
    if (data.comment.deleted && data.comment.deleted === true) {
      commentData.deleted = true;
    }

    await ref.commentDoc(data.comment.id).set(commentData);
    return ref.commentDoc(data.comment.id);
  }
}

/**
 * Create a user for test
 *
 * @param {*} uid
 * @returns
 */
async function createTestUser(uid) {
  const timestamp = new Date().getTime();

  const userData = {
    nickname: "testUser" + timestamp,
    registeredAt: timestamp,
  }

  await rdb
      .ref("users")
      .child(uid)
      .set(userData);
  return rdb.ref("users").child(uid);
}

exports.createCategory = createCategory;
exports.createPost = createPost;
exports.createComment = createComment;
exports.createTestUser = createTestUser;
