import "mocha";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Utils } from "../../src/classes/utils";
import { User } from "../../src/classes/user";
import { Messaging } from "../../src/classes/messaging";

import { expect } from "chai";
import { Ref } from "../../src/classes/ref";

new FirebaseAppInitializer();

describe("resubscribe test", () => {
  it("resubscribe on User login", async () => {
    const stamp = Utils.getTimestamp();
    const a = "uc-a-" + stamp;

    await User.create(a, { firstName: "uc-" + stamp });
    const userA = await User.get(a);

    await Messaging.updateToken({ uid: a, token: "fake-token-1" });

    const tokens = await Messaging.getTokens(a);
    if (tokens) {
      // expect(tokens.length).to.be.equal(1);
      expect(tokens).include("fake-token-1");
    } else {
      expect.fail("must not empty tokens");
    }
    await Ref.userSettingForumTopics(a).update({ ["post_" + stamp]: true });
    await Ref.userSettingForumTopics(a).update({ ["comment_" + stamp]: false });

    const forumSubs = await Messaging.getSubscribedForum(a);
    if (tokens) {
      expect(forumSubs.length).to.be.equal(1);
      expect(forumSubs).include("post_" + stamp);
    } else {
      expect.fail("must not empty subs");
    }

    const res = await Messaging.resubscribeTopics(userA!, a);
    // user has no valid token
    expect(res).to.be.equal(null);
    // add valid token
    await Messaging.updateToken({
      uid: a,
      token:
        "eTb93wtfj0z4vsZEvEoPQ4:APA91bHBz3msWxf4VvaBXeRxgpord3JWaiDAkioKxQF-WxrT4FCXuzzDVlV8dXXWFefm3ANFzAti0ciYgkJDyRAXc-5Oj7T_kZXNJ5E5DockQ831RJadTtHkB54vlHey3rWijbOR_FZr",
    });
    await Messaging.updateToken({ uid: a, token: "fake-token-2" });
    await Messaging.updateToken({ uid: a, token: "aafake-token-1" });
    // const res1 = await Messaging.resubscribeToSubscriptions(userA!, a);
    // console.log(res1);
    // if (res1) {
    //   expect(res1.uid).to.be.equal(a);
    //   // expect(res1.tokens.length).to.be.equal(3);
    //   expect(res1.forumSubs.length).to.be.equal(1);
    // } else {
    //   expect.fail("must not be fail");
    // }
  });
});
