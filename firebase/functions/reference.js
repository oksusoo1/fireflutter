const admin = require("firebase-admin");
// get firestore
const db = admin.firestore();

/**
 * Returns category referrence
 *
 * @param {*} id Category id
 * @return reference
 */
function categoryDoc(id) {
  return db.collection("categories").doc(id);
}

/**
 * Returns post reference
 * @param {*} id post id
 * @return reference
 */
function postDoc(id) {
  return db.collection("posts").doc(id);
}

/**
 * Returns comment refernce
 * @param {*} id comment id
 * @return reference
 */
function commentDoc(id) {
  return db.collection("comments").doc(id);
}

exports.categoryDoc = categoryDoc;
exports.postDoc = postDoc;
exports.commentDoc = commentDoc;
