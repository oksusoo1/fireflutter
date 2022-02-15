import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as axios from "axios";


admin.initializeApp();

export const sendMessageOnPostCreate = functions
    .region("asia-northeast3")
    .firestore
    .document("/posts/{postId}")
    .onCreate(async (snapshot) => {
        const category = snapshot.data().category;
        const payload = {
            notification: {
                title: 'title: ' + snapshot.data().title,
                body: snapshot.data().content,
            },
        };
        const topic = "posts_" + category;
        console.info("topic; ", topic);
        return admin.messaging().sendToTopic(topic, payload);
    });


//
export const meilisearchIndexPost = functions
    .region("asia-northeast3").firestore
    .document("/posts/{postId}")
    .onCreate((snap, context) => {
        const data = {
            id: context.params.postId,
            title: snap.data().title,
            content: snap.data().content
        };
        return axios.default.post(
            `http://wonderfulkorea.kr:7700/indexes/users/documents`,
            data,
            { headers: { "X-Meili-API-Key": 'mmk' } }
        )
    });


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
