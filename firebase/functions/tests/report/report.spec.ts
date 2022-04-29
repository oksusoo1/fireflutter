import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Report, ReportDocument } from "../../src/classes/report";
import {
  ERROR_ALREADY_REPORTED,
  ERROR_EMPTY_REASON,
  ERROR_EMPTY_TARGET,
  ERROR_EMPTY_TARGET_ID,
  ERROR_EMPTY_UID,
  ERROR_WRONG_TARGET,
} from "../../src/defines";

import { Utils } from "../../src/classes/utils";

new FirebaseAppInitializer();

describe("Report test", () => {
  it("Input error test", async () => {
    await Report.create({} as any).catch((e) => {
      expect(e).equals(ERROR_EMPTY_UID);
    });
    await Report.create({
      uid: "...uid...",
    } as any).catch((e) => {
      expect(e).equals(ERROR_EMPTY_TARGET);
    });
    await Report.create({
      uid: "...uid...",
      target: "...",
    } as any).catch((e) => {
      expect(e).equals(ERROR_WRONG_TARGET);
    });
    await Report.create({
      uid: "...uid...",
      target: "post",
    } as any).catch((e) => {
      expect(e).equals(ERROR_EMPTY_TARGET_ID);
    });

    await Report.checkInput({
      uid: "...uid...",
      target: "post",
      targetId: "... target id ...",
    } as ReportDocument).catch((e) => {
      expect(e).equals(ERROR_EMPTY_REASON);
    });
    await Report.checkInput({
      uid: "...uid...",
      target: "post",
      targetId: "... target id ... ",
      reason: "",
    } as ReportDocument);
  });

  it("Create a report", async () => {
    const data = {
      uid: "a",
      target: "post",
      targetId: "post-id-" + Utils.getTimestamp(),
      reason: "",
    };
    const report = await Report.create(data);
    expect(report.id === Report.getReportId(data)).true;
  });

  it("Already reported", async () => {
    const data = {
      uid: "a",
      target: "post",
      targetId: "post-id-already-created-" + Utils.getTimestamp(),
      reason: "",
    };
    const report = await Report.create(data);
    expect(report.id === Report.getReportId(data)).true;

    await Report.create(data).catch((e) => {
      expect(e).equal(ERROR_ALREADY_REPORTED);
    });
  });
});
