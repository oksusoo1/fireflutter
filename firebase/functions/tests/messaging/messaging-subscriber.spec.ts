import "mocha";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Test } from "../../src/classes/test";
import { Utils } from "../../src/classes/utils";

import { Messaging } from "../../src/classes/messaging";
import { expect } from "chai";
import { Ref } from "../../src/classes/ref";

new FirebaseAppInitializer();

describe("Subscriber test", () => {
  it("get topic subscriber test", async () => {
    // Create two users
    const a = "TS1-" + Utils.getTimestamp();
    const b = "TS2-" + Utils.getTimestamp();
    await Test.createTestUserAndGetDoc(a);
    await Test.createTestUserAndGetDoc(b);

    const uids = await Messaging.removeUserHasSubscriptionOff([a, b].join(","), "subs-1");
    expect(uids).to.be.an("array").contain(a);
    expect(uids).contain(b);

    await Ref.userSettingTopic(a).update({ ["chatNotify" + a]: false });
    const uids1false = await Messaging.removeUserHasSubscriptionOff([a, b].join(","), "chatNotify" + a);
    expect(uids1false).to.be.an("array").contain(b);
    expect(uids1false).not.include(a);
    expect(uids1false.length).equal(1);

    await Ref.userSettingTopic(a).update({ ["chatNotify" + a]: true });
    await Ref.userSettingTopic(b).update({ ["chatNotify" + a]: false });
    const uids1true1false = await Messaging.removeUserHasSubscriptionOff([a, b].join(","), "chatNotify" + a);
    expect(uids1true1false).to.be.an("array").contain(a);
    expect(uids1true1false).not.include(b);
    expect(uids1true1false.length).equal(1);
  });
});
