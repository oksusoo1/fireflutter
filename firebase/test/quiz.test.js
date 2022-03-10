/**
 * @file quiz.test.js
 * @description This is not part of fireflutter. You may delete or ignore it.
 */
const firebase = require("@firebase/testing");
const { auth } = require("firebase");
const TEST_PROJECT_ID = "withcenter-test-project";
const A = "user_A";
const B = "user_B";
const C = "user_C";
const authA = { uid: A, email: A + "@gmail.com" };
const authB = { uid: B, email: B + "@gmail.com" };
const authC = { uid: C, email: C + "@gmail.com" };
function db(auth = null) {
  return firebase.initializeTestApp({ projectId: TEST_PROJECT_ID, auth: auth }).firestore();
}
function admin() {
  return firebase.initializeAdminApp({ projectId: TEST_PROJECT_ID }).firestore();
}

function createSampleQuestion(quizId) {
  return admin()
    .collection("posts")
    .doc(quizId)
    .set({ title: "Does South Korea have autumn?", a: "Yes", b: "No", answer: "a" });
}

// Delete data before each test
beforeEach(async () => {
  await firebase.clearFirestoreData({ projectId: TEST_PROJECT_ID });
});

describe("Firestore security test for Quiz", () => {
  it("Create sample data and read test", async () => {
    await createSampleQuestion("doc_id_a");
    /// Reading by admin
    await firebase.assertSucceeds(admin().collection("posts").doc("doc_id_a").get());
    /// Reading by anonymous
    await firebase.assertSucceeds(db().collection("posts").doc("doc_id_a").get());
  });
  it("Expect fail - answering the quiz with wrong uid", async () => {
    await createSampleQuestion("quizId");

    // fails due to UID does not match.
    await firebase.assertFails(
      db()
        .collection("quiz-history")
        .doc(A)
        .set({ quizId: { answer: "a", result: true } }, { merge: true })
    );
  });

  it("Expect success", async () => {
    await createSampleQuestion("quizId");
    await firebase.assertSucceeds(
      db(authA)
        .collection("quiz-history")
        .doc(A)
        .set({ quizId: { answer: "a", result: true } }, { merge: true })
    );
  });

  it("Expect success - for update", async () => {
    await createSampleQuestion("quizId");
    await firebase.assertSucceeds(
      db(authA)
        .collection("quiz-history")
        .doc(A)
        .set({ quizId: { answer: "a", result: true } }, { merge: true })
    );

    await firebase.assertSucceeds(
      db(authA)
        .collection("quiz-history")
        .doc(A)
        .update({ quizId: { answer: "b", result: false } })
    );

    await firebase.assertSucceeds(
      db(authA)
        .collection("quiz-history")
        .doc(A)
        .update({ quizId_2: { answer: "d", result: false } })
    );

    await firebase.assertSucceeds(db(authA).collection("quiz-history").doc(A).get());
  });
});
