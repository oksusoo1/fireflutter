import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();


/// Update noOfPosts in category setting
export const incrementNoOfPost = functions.firestore.document('/posts/{postId}')
    .onCreate((snap, context) => {
        const ref = admin.firestore().collection('categories').doc(snap.data().category);
        return ref.update({
            noOfPosts: admin.firestore.FieldValue.increment(1),
        });
    });


/// Update noOfComments in the post.
export const incrementNoOfComment = functions.firestore.document('/comment/{commentId}')
    .onCreate((snap, context) => {
        const ref = admin.firestore().collection('posts').doc(snap.data().postId);
        return ref.update({
            noOfComments: admin.firestore.FieldValue.increment(1),
        });
    });