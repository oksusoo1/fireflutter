import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { User } from "../../src/classes/user";
import { Ref } from "../../src/classes/ref";
import { ERROR_SIGNIN_TOKEN_NOT_EXISTS } from "../../src/defines";
import { SignInToken } from "../../src/interfaces/user.interface";

new FirebaseAppInitializer();

describe("User sign-in token test", () => {
  it("Create token and read the token", async () => {
    const docId = "N123T";
    const uid = "apple@test_com";
    await Ref.signInTokenDoc(docId).set({ uid: uid });
    const doc = (await Ref.signInTokenDoc(docId).get()).val() as SignInToken;
    expect(doc).to.be.an("object").to.have.property("uid").equal(uid);
    const user = await User.getSignInToken({ id: docId });
    expect(user?.id == doc.uid).true;
    try {
      await User.getSignInToken({ id: docId });
      expect.fail("Cannot get the token twice");
    } catch (e) {
      expect(e).equals(ERROR_SIGNIN_TOKEN_NOT_EXISTS);
    }
  });
});
