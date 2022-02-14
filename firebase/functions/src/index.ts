import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

export const sendMessageOnPostCreate = functions
    .region('asia-northeast3')
    .firestore
    .document("/posts/{postId}")
    .onCreate((snapshot, context) => {
        const category = snapshot.data().category;
        const payload = {
            notification: {
                title: 'You have a new post!',
                body: `... is now following you.`
            }
        };

        return admin.messaging().sendToTopic('posts_' + category, payload);
    });


// // Update noOfPosts in category setting
// export const incrementNoOfPost = functions
//     .region("asia-northeast3").firestore
//     .document("/posts/{postId}")
//     .onCreate((snap) => {
//       const ref = admin.firestore()
//           .collection("categories")
//           .doc(snap.data().category);
//       return ref.update({
//         noOfPosts: admin.firestore.FieldValue.increment(1),
//       });
//     });


// // Update noOfComments in the post.
// export const incrementNoOfComment = functions
//     .region("asia-northeast3").firestore
//     .document("/comment/{commentId}")
//     .onCreate((snap) => {
//       const ref = admin.firestore()
//           .collection("posts")
//           .doc(snap.data().postId);
//       return ref.update({
//         noOfComments: admin.firestore.FieldValue.increment(1),
//       });
//     });
