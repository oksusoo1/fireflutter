import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { User } from "../../src/classes/user";
import { ERROR_YOU_ARE_NOT_ADMIN } from "../../src/defines";

import { Test } from "../../src/classes/test";
import { Ref } from "../../src/classes/ref";

import * as admin from "firebase-admin";

new FirebaseAppInitializer();

describe("Admin User management test", () => {
  it("Admin block and unblock user.", async () => {
    // registered ids via auth
    const userA = "ddLo0QHMvhZBbG9v7zBU8WUod4o2";
    const userB = "k0QDjEXgWwSXsBe6zHVozxCYxp23";
    const userC = "lZ6YejW9bDZ1EBSZL2SQn1okTRz2";

    const refA = await Ref.user(userA).get();
    if (!refA.exists()) await Test.createTestUser(userA);

    const refB = await Ref.user(userA).get();
    if (!refB.exists()) await Test.createTestUser(userB);
    const refC = await Ref.user(userA).get();
    if (!refC.exists()) await Test.createTestUser(userC);

    // set userA as admin
    await Ref.adminDoc.set({ [userA]: true }, { merge: true });
    let re = (await User.disableUser({ uid: userB }, {})) as {
      code: string;
      message: string;
    };
    expect(re["code"]).equal(ERROR_YOU_ARE_NOT_ADMIN, "should be error since user not provided");

    re = (await User.disableUser({ uid: userB }, { auth: { uid: userC } })) as {
      code: string;
      message: string;
    };
    expect(re["code"]).equal(ERROR_YOU_ARE_NOT_ADMIN, "should be error since user userC not admin");

    const ret = (await User.disableUser(
        { uid: userB },
        { auth: { uid: userA } }
    )) as admin.auth.UserRecord;
    const c = (await User.disableUser(
        { uid: userC },
        { auth: { uid: userA } }
    )) as admin.auth.UserRecord;
    expect(ret["uid"]).equal(userB, "userB uid");
    expect(ret["disabled"]).equal(true, "userB must be disabled true");
    expect(c["disabled"]).equal(true, "userC must be disabled true");

    let res = await Ref.users.orderByChild("disabled").equalTo(true).get();
    expect(res.exists(), "users must exist with disable true");
    let users = res.val();
    expect(users[userB].disabled == true, "userB must exist with disable true");
    expect(users[userC].disabled == true, "userC must exist with disable true");

    res = await Ref.users.child(userB).get();
    let user = res.val();
    expect(res.exists, "user must exist");
    expect(user.disabled == true, "user marked as disabled");

    const b2 = (await User.enableUser(
        { uid: userB },
        { auth: { uid: userA } }
    )) as admin.auth.UserRecord;
    const c2 = (await User.enableUser(
        { uid: userC },
        { auth: { uid: userA } }
    )) as admin.auth.UserRecord;
    expect(b2["uid"] == userB, "userB uid for enabling user");
    expect(b2["disabled"] == false, "userB must be disabled false");
    expect(c2["disabled"] == false, "userC must be disabled false");

    res = await Ref.users.orderByChild("disabled").equalTo(false).get();
    expect(res.exists(), "users must exist with disable true");
    users = res.val();
    expect(users[userB].disabled == false, "userB must exist with disable false");
    expect(users[userC].disabled == false, "userC must exist with disable false");

    res = await Ref.users.child(userB).get();
    user = res.val();
    expect(user.disabled == false, "user marked as disabled as false");
  });
});
