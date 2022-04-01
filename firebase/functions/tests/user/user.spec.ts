import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { User } from "../../src/classes/user";
import { Utils } from "../../src/classes/utils";
import { ERROR_AUTH_FAILED, ERROR_EMPTY_PASSWORD, ERROR_EMPTY_UID } from "../../src/defines";

new FirebaseAppInitializer();

describe("User test", () => {
  it("User create", async () => {
    const id = "uid-a-" + Utils.getTimestamp();
    await User.create(id, {
      firstName: "fn",
    });
    const user = await User.get(id);
    expect(user).to.be.an("object").to.have.property("id").equal(id);
  });
  it("User authentication", async () => {
    expect((await User.authenticate({ uid: "", password: "" })) === ERROR_EMPTY_UID).true;
    expect((await User.authenticate({ uid: "oo", password: "" })) === ERROR_EMPTY_PASSWORD).true;

    const id = "uid-a-" + Utils.getTimestamp();
    await User.create(id, {
      firstName: "fn",
    });
    const user = await User.get(id);
    const re = await User.authenticate({ uid: user!.id, password: "wrong password" });
    expect(re === ERROR_AUTH_FAILED).true;
    const right = await User.authenticate({ uid: user!.id, password: user!.password });
    expect(right === "").true;
    console.log("uid; ", user!.id, "password; ", user!.password);
  });
});
