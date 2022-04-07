import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { User } from "../../src/classes/user";
import { Utils } from "../../src/classes/utils";
import { ERROR_WRONG_PASSWORD, ERROR_EMPTY_PASSWORD, ERROR_EMPTY_UID } from "../../src/defines";

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
    expect(re === ERROR_WRONG_PASSWORD).true;

    const password = User.generatePassword(user!);
    const right = await User.authenticate({ uid: user!.id, password: password });

    expect(right === "", right).true;
  });
});
