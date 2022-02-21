"use strict";

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Axios = require("axios");

const { MeiliSearch } = require('meilisearch')


// get firestore
const db = admin.firestore();

// get real time database
const rdb = admin.database();

const delay = time => new Promise(res=>setTimeout(res,time));


function categoryDoc(id) {
  return db.collection('categories').doc(id);
}
function postDoc(id) {
  return db.collection('posts').doc(id);
}
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

/**
 * 
 * @param {*} data 
 * @returns reference of the cateogry
 */
async function createCategory(data) {
  const id = data.id;
  // delete data.id; // call-by-reference. it will causes error after this method.
  data.timestamp = (new Date).getTime();
  const writeResult = await categoryDoc(id).set(data, { merge: true });
  return categoryDoc(id);
}

/**
 * 
 * @returns reference
 */
async function createPost(data) {

  // if data.category.id comes in, then it will prepare the category to be exist.
  if ( data.category && data.category.id ) {
    const catDoc = await createCategory(data.category);
    // console.log((await catDoc.get()).data());
    // console.log('category id; ', catDoc.id);
  }
  
  const postData = {
    category: data.category && data.category.id ? data.category.id : 'test',
    title: data.post && data.post.title ? data.post.title : 'create_post',
    uid: data.post && data.post.uid ? data.post.uid : 'uid'
  };

  if ( data.post && data.post.id ) {
    if (data.post.deleted && data.post.deleted === true) {
      postData.deleted = true;
    }
    
    await postDoc(data.post.id).set(postData), {merge: true};
    return postDoc(data.post.id);
  } else {
    return db.collection('posts').add(postData);
  }
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
  if ( data.category && data.category.id ) {
    await createCategory(data.category);
  }

  let commentData;
  // If there is no postId in data, then create one.
  if ( data.post ) {
    const ref = await createPost(data);

    commentData = {
      postId: ref.id,
      parentId: ref.id,
      content: data.comment.content,
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
  if ( ! data.comment.id ) {
    return db.collection('comments').add(commentData);
  } else {
    if (data.comment.deleted && data.comment.deleted === true) {
      commentData.deleted = true;
    }

    await commentDoc(data.comment.id).set(commentData);
    return commentDoc(data.comment.id);
  }
}

async function createTestUser(uid) {
  const timestamp = (new Date).getTime();
  const res = await rdb.ref('users').child(uid).set({
    nickname: 'testUser' + timestamp,
    timestamp_registered: timestamp,
  })
  return rdb.ref('users').child(uid);
}


async function indexPostDocument(id, data) {
  const _data = {
      id: id,
      uid: data.uid,
      title: data.title,
      category: data.category,
      content: data.content,
      timestamp: data.timestamp ?? Date.now(),
  };

  await Axios.post(
      "http://wonderfulkorea.kr:7700/indexes/posts/documents",
      _data
  );
  return indexForumDocument(_data);
}

async function indexCommentDocument(id, data) {
  const _data = {
      id: id,
      uid: data.uid,
      postId: data.postId,
      content: data.content,
      timestamp: data.timestamp ?? Date.now(),
  };
  await Axios.post(
      "http://wonderfulkorea.kr:7700/indexes/comments/documents",
      _data
  );
  return indexForumDocument(_data);
}

function indexForumDocument(data) {
  return Axios.post(
    "http://wonderfulkorea.kr:7700/indexes/posts-and-comments/documents",
    data
  );
}

async function deleteIndexedPostDocument(id) {
  await Axios.delete("http://wonderfulkorea.kr:7700/indexes/posts/documents/" + id);
  return deleteIndexedForumDocument(id);
}

async function deleteIndexedCommentDocument(id) {
  await Axios.delete("http://wonderfulkorea.kr:7700/indexes/comments/documents/" + id);
  return deleteIndexedForumDocument(id);
}

async function deleteIndexedForumDocument(id) {
  return Axios.delete("http://wonderfulkorea.kr:7700/indexes/posts-and-comments/documents/" + id);
}

// get comment ancestor by getting parent comment until it reach the root comment
// return the uids of the author
async function getCommentAncestors(id, authorUid) {
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


// check the uids if they are subscribe to topic and also want to get notification under their post/comment
async function removeTopicAndForumAncestorsSubscriber(uids, topic) {
  const _uids = [];
  const getTopicsPromise = [];
  for(let uid of uids ) {
      getTopicsPromise.push( rdb.ref('user-settings').child(uid).child('topic').get());
      // getTopicsPromise.push( admin.database().ref('user-settings').child(uid).child('topic').once('value'));  // same result above
  } 
  const result = await Promise.all(getTopicsPromise);
  for(let i in result) { 
    const v = result[i].val();
    if(v['newCommentUnderMyPostOrCOmment'] != null && v['newCommentUnderMyPostOrCOmment'] == true && (v[topic] == null || v[topic] == false)) {
      _uids.push(uids[i]);
    }
  }  
  return _uids;
}

async function getTokensFromUid(uids) {
  const _tokens = [];
  const getTokensPromise = [];
  for(let u of uids) {
    getTokensPromise.push(admin.firestore().collection('message-tokens').where('uid', '==', u).get());
  }

  const result = await Promise.all(getTokensPromise);
  for(let tokens of result) { 
    if(tokens.size == 0) continue;
    for( let doc of tokens.docs) {
      _tokens.push(doc.id);
    }
  }   
  return _tokens;
}

function chunk(arr, chunkSize) {
  if (chunkSize <= 0) throw "Invalid chunk size";
  var R = [];
  for (var i=0,len=arr.length; i<len; i+=chunkSize)
    R.push(arr.slice(i,i+chunkSize));
  return R;
}



exports.delay = delay;
exports.getSizeOfCategories = getSizeOfCategories;
exports.getCategories = getCategories;
exports.createCategory = createCategory;
exports.createPost = createPost;
exports.createComment = createComment;


exports.createTestUser = createTestUser;


exports.indexComment = indexCommentDocument;
exports.indexPost = indexPostDocument;

exports.deleteIndexedPost = deleteIndexedPostDocument;
exports.deleteIndexedComment = deleteIndexedCommentDocument;

exports.getCommentAncestors = getCommentAncestors;
exports.removeTopicAndForumAncestorsSubscriber = removeTopicAndForumAncestorsSubscriber;
exports.getTokensFromUid = getTokensFromUid;
exports.chunk = chunk;