"use strict";

const functions = require("firebase-functions");
const admin = require("firebase-admin");


// get firestore
const db = admin.firestore();

function commentDoc(id) {
  return db.collection('comments').doc(id);
}


function getCategories()  {
  return db.collection("categories").get();
}

async function getSizeOfCategories() {
  const snapshot = await getCategories();
  return snapshot.size;
}

async function createCategory(data) {
  return db.collection('categories').doc(
    data.category ? data.category : 'test',
  ).set({title: 'create category'});
}

/**
 * 
 * @returns reference
 */
async function createPost(data) {
  const postData = {
    category: data.category ? data.category : 'test',
    title: data.title ? data.title : 'create_post',
    uid: data.uid ? data.uid : 'uid',
  };
  if ( data.post.id ) {
    await db.collection('posts').doc(data.post.id).set(postData);
    return db.collection('posts').doc(data.post.id);
  }
  return db.collection('posts').add(postData);
}

/**
 * 
 * @returns reference
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
  if ( data.category) await createCategory(data);
  
  let commentData;
  // If there is no postId in data, then create one.
  if ( data.post && !data.post.postId ) {
    const ref = await createPost(data);
    commentData = {
      postId: ref.id,
      parentId: ref.id,
      content: 'create comment',
      uid: data.comment.uid ? data.comment.uid : 'uid',
    };
  } else {
    commentData = {
      postId: data.comment.postId,
      parentId: data.comment.parentId,
      content: data.comment.content ? data.comment.content : '',
      uid: data.comment.uid ? data.comment.uid : 'uid',
    };
  }
  // if no comment id, then create one
  if ( ! data.comment.id ) return db.collection('comments').add(commentData);
  else {
    await commentDoc(data.comment.id).set(commentData);
    return commentDoc(data.comment.id);
  }
}

exports.getSizeOfCategories = getSizeOfCategories;
exports.getCategories = getCategories;
exports.createCategory = createCategory;
exports.createPost = createPost;
exports.createComment = createComment;




// get comment ancestor by getting parent comment until it reach the root comment
// return the uids of the author
 exports.getCommentAncestors = async function (id, authorUid) {
    let comment = await commentDoc(id).get();
    const uids = [];
    while(true) {
      if (comment.data().postId == comment.data().parentId ) break;
      comment = await commentDoc(comment.data().parentId).get();
      if(comment.exists == false) continue;
      if(comment.data().uid == authorUid) continue; // skip the author's uid.
      uids.push(comment.data().uid);
    }
    return uids.filter((v, i, a) => a.indexOf(v) === i);  // remove duplicate
  }
