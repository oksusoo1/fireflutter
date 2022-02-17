  // get comment ancestor by getting parent comment until it reach the root comment
  // return the uids of the author
 exports.getCommentAncestors = async function (id, authorUid) {
    let comment = await admin.firestore().collection('comments').doc(id).get();
    const uids = [];
    while(true) {
      if (comment.data().postId == comment.data().parentId ) break;
      comment = await admin.firestore().collection('comments').doc(comment.data().parentId).get();
      if(comment.exists == false) continue;
      if(comment.data().uid == authorUid) continue; //get author uid.
      uids.push(comment.data().uid);
    }
    return uids.filter((v, i, a) => a.indexOf(v) === i);  // remove duplicate
  }
