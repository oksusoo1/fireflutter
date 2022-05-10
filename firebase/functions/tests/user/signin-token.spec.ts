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
    await Ref.signInTokenDoc(docId).set({ uid: "uid321", password: "password321" });
    const doc = (await Ref.signInTokenDoc(docId).get()).val() as SignInToken;
    expect(doc).to.be.an("object").to.have.property("uid").equal("uid321");
    const token = await User.getSignInToken(docId);
    expect(token.uid == doc.uid).true;
    expect(token.password == doc.password).true;

    try {
      await User.getSignInToken(docId);
      expect.fail("Cannot get the token twice");
    } catch (e) {
      expect(e).equals(ERROR_SIGNIN_TOKEN_NOT_EXISTS);
    }
  });
});
