import "mocha";
// import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { User } from "../../src/classes/user";
import { Ref } from "../../src/classes/ref";
// import { Utils } from "../../src/classes/utils";
// import { ERROR_WRONG_PASSWORD, ERROR_EMPTY_PASSWORD, ERROR_EMPTY_UID } from "../../src/defines";

new FirebaseAppInitializer();

const userA = "ddLo0QHMvhZBbG9v7zBU8WUod4o2";

describe("User admin search", async () => {
  it("search user", async () => {
    // set userA as admin

    await Ref.adminDoc.set({ [userA]: true }, { merge: true });
    try {
      const result = await User.adminUserSearch({ disabled: true }, { auth: { uid: userA } });
      console.log(result);
    } catch (e) {
      console.log(e);
    }
  });

  //   it("User authentication", async () => {});
});
