import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { User } from "../../src/classes/user";
import { Ref } from "../../src/classes/ref";
// import {
//   ERROR_EMTPY_EMAIL_AND_PHONE_NUMBER,
//   ERROR_ONE_OF_EMAIL_AND_PHONE_NUMBER_MUST_BY_EMPTY,
//   ERROR_USER_NOT_FOUND,
//   ERROR_YOU_ARE_NOT_ADMIN,
// } from "../../src/defines";
// import { ErrorCodeMessage } from "../../src/interfaces/common.interface";
import { UserRecord } from "firebase-admin/lib/auth/user-record";

new FirebaseAppInitializer();

const userA = "ddLo0QHMvhZBbG9v7zBU8WUod4o2";

describe("User admin search", async () => {
  // it("admin search", async () => {
  //   try {
  //     const result = (await User.adminUserSearch({}, {})) as ErrorCodeMessage;
  //     expect(result.code).equal(ERROR_YOU_ARE_NOT_ADMIN, "user context is empty");
  //   } catch (e) {
  //     console.log(e);
  //     expect.fail("must not throw error1");
  //   }
  // });
  // it("ERROR_EMTPY_EMAIL_AND_PHONE_NUMBER", async () => {
  //   await Ref.adminDoc.set({ [userA]: true }, { merge: true });
  //   try {
  //     const result = await User.adminUserSearch({}, { auth: { uid: userA } });
  //     expect(result).equal(ERROR_EMTPY_EMAIL_AND_PHONE_NUMBER);
  //   } catch (e) {
  //     console.log(e);
  //     expect.fail("must not throw error2");
  //   }
  // });
  // it("ERROR_ONE_OF_EMAIL_AND_PHONE_NUMBER_MUST_BY_EMPTY", async () => {
  //   await Ref.adminDoc.set({ [userA]: true }, { merge: true });
  //   try {
  //     const result = await User.adminUserSearch(
  //         { email: "abc", phoneNumber: "+123" },
  //         { auth: { uid: userA } }
  //     );
  //     expect(result).equal(ERROR_ONE_OF_EMAIL_AND_PHONE_NUMBER_MUST_BY_EMPTY);
  //   } catch (e) {
  //     console.log(e);
  //     expect.fail("must not throw error3");
  //   }
  // });

  // it("fake email", async () => {
  //   await Ref.adminDoc.set({ [userA]: true }, { merge: true });
  //   try {
  //     const result = await User.adminUserSearch(
  //         { email: "fake@gmail.com" },
  //         { auth: { uid: userA } }
  //     );
  //     expect(result).equal(ERROR_USER_NOT_FOUND);
  //   } catch (e) {
  //     console.log(e);
  //   }
  // });

  // it("fake phoneNumber", async () => {
  //   await Ref.adminDoc.set({ [userA]: true }, { merge: true });
  //   try {
  //     const result = await User.adminUserSearch(
  //         { phoneNumber: "+123456" },
  //         { auth: { uid: userA } }
  //     );
  //     expect(result).equal(ERROR_USER_NOT_FOUND);
  //   } catch (e) {
  //     console.log(e);
  //     expect.fail(e);
  //   }
  // });

  it("valid email", async () => {
    await Ref.adminDoc.set({ [userA]: true }, { merge: true });
    try {
      const user = (await User.adminUserSearch(
          {
            email: "thruthesky@gmail.com",
          },
          { auth: { uid: userA } }
      )) as UserRecord;
      console.log(user);
      expect(user.email).equal("thruthesky@gmail.com");
    } catch (e) {
      console.log(e);
      expect.fail(e);
    }
  });
  // it("valid number", async () => {
  //   await Ref.adminDoc.set({ [userA]: true }, { merge: true });
  //   try {
  //     const user = (await User.adminUserSearch(
  //         {
  //           phoneNumber: "+639152308483",
  //         },
  //         { auth: { uid: userA } }
  //     )) as UserRecord;

  //     expect(user.email).equal("pinedaclp@gmail.com");
  //   } catch (e) {
  //     console.log(e);
  //     expect.fail(e);
  //   }
  // });
});
