"use strict";

const admin = require("firebase-admin");
const faker = require("@faker-js/faker").faker;

// initialize the firebase
if (!admin.apps.length) {
  const serviceAccount = require("../firebase-admin-sdk-key.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL:
      "https://withcenter-test-project-default-rtdb.asia-southeast1.firebasedatabase.app/",
  });
}

// get real time database
const rdb = admin.database();

// admin
//   .auth()
//   .getUser("gqXfS8GAUKfrpjfYNPM1xPQXY8i1")
//   .then((record) => {
//     console.log(record);
//   })
//   .catch((e) => {
//     console.log(e);
//   });

const photoUrls = [
  "https://firebasestorage.googleapis.com/v0/b/wonderful-korea.appspot.com/o/uploads%2F007eb6c6-6e39-462f-adde-d9cafb0cefd6.jpg?alt=media&token=1685bbcb-c28c-4f5c-b705-3899049f2042",
  "https://firebasestorage.googleapis.com/v0/b/wonderful-korea.appspot.com/o/uploads%2F01926759-7e5f-49c6-ba7b-daea4b130f40.jpg?alt=media&token=de19e78f-350b-448a-9f9e-d70fc436acc0",
  "https://firebasestorage.googleapis.com/v0/b/wonderful-korea.appspot.com/o/uploads%2F03686acf-a714-4128-b10a-b1cf498ef732.png?alt=media&token=a3e34363-8a85-496e-a669-b4ba449989b6",
  "https://firebasestorage.googleapis.com/v0/b/wonderful-korea.appspot.com/o/uploads%2F060d5315-ce36-4b57-a266-1e7fa17541a2.jpg?alt=media&token=81ed4efd-3249-471e-b6c4-3ea802080fc2",
  "https://firebasestorage.googleapis.com/v0/b/wonderful-korea.appspot.com/o/uploads%2F08a05906-92eb-4758-99a3-119c22fb2074.jpg?alt=media&token=16d23896-2f30-4aad-8857-821fd3d61dce",
  "https://firebasestorage.googleapis.com/v0/b/wonderful-korea.appspot.com/o/uploads%2F0b5dc783-d20e-4259-9f68-d8fb7a3d0b0f.jpeg?alt=media&token=75705c2d-7ed1-4286-b6d1-b2791f125dfc",
  "https://firebasestorage.googleapis.com/v0/b/wonderful-korea.appspot.com/o/uploads%2F0c8ee315-5105-45be-830c-d0a9b9acb51f.jpg?alt=media&token=b9c7b0a1-aade-41c9-bcd0-490836a099ea",
  "https://firebasestorage.googleapis.com/v0/b/wonderful-korea.appspot.com/o/uploads%2F0f5ae7ae-31c0-4068-b54f-3b595d961d9d.jpg?alt=media&token=c1067ac3-a11a-474a-a68d-d5e8be0f770d",
  "https://firebasestorage.googleapis.com/v0/b/wonderful-korea.appspot.com/o/uploads%2F13eb21ee-9f98-4106-acd5-0fb02085d954.png?alt=media&token=24c06c86-f8af-49eb-b77b-63b4048a1508",
  "https://firebasestorage.googleapis.com/v0/b/wonderful-korea.appspot.com/o/uploads%2F22336e15-8b50-487d-8ac8-d1ade3c842b0.jpg?alt=media&token=5a4acc7e-507c-42ad-9461-245f56d614cf",
];
console.log("\n\n----------> Creating test users\n");
for (let i = 1; i <= 10; i++) {
  let email = "";
  if (i == 1) email = "apple@test.com";
  else if (i == 2) email = "banana@test.com";
  else if (i == 3) email = "cherry@test.com";
  else if (i == 4) email = "durian@test.com";
  else email = "test" + i + "@gmail.com";

  let uid = email.replace(".", "_");

  const firstName = faker.name.firstName();
  const lastName = faker.name.lastName();
  const phoneNumber = faker.phone.phoneNumber("+6391########");
  const birthday = 19990123;
  const gender = faker.random.arrayElement(["M", "F"]);

  admin
    .auth()
    .createUser({
      uid: uid,
      email: email,
      emailVerified: true,
      phoneNumber: phoneNumber,
      password: "12345a",
      disabled: false,
    })
    .then((userRecord) => {
      // See the UserRecord reference doc for the contents of userRecord.
      console.log("Successfully created new user:", userRecord.uid);
    })
    .catch((error) => {
      if (error.code == "auth/uid-already-exists") {
        console.log(email, error.code);
      } else if (error.code == "auth/email-already-exists") {
        console.log(email, error.code);
      } else {
        console.log("Error creating new user:", error.code);
      }
    });

  rdb
    .ref("users")
    .child(uid)
    .set({
      firstName: firstName,
      lastName: lastName,
      birthday: birthday,
      gender: gender,
      photoUrl: photoUrls[i - 1],
      profileReady: true,
      registeredAt: admin.database.ServerValue.TIMESTAMP,
      updatedAt: admin.database.ServerValue.TIMESTAMP,
    });
}
