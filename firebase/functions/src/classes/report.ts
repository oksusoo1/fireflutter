import {
  ERROR_ALREADY_REPORTED,
  ERROR_EMPTY_REASON,
  ERROR_EMPTY_TARGET,
  ERROR_EMPTY_TARGET_ID,
  ERROR_EMPTY_UID,
  ERROR_FAILED_TO_CREATE_REPORT,
  ERROR_WRONG_TARGET,
} from "../defines";
import { Ref } from "./ref";
import { Utils } from "./utils";

// uid is the reporter id
export interface ReportDocument {
  id?: string; // Report document id. It will be available on read only.
  uid: string; // The uid of reporter.
  reporteeUid?: string; // The uid of reportee.
  target: string;
  targetId: string; // the document id of target.
  reason: string;
  timestamp?: number; // unix time stamp of creation.
}

export class Report {
  static targets = ["post", "comment", "user"];

  /**
   * Check the input data and throw execption if there is any error.
   *
   * @param data data to create a report
   *
   *
   * Note, the exception may be delivered to the client directly.
   * Note, It does not check if the targetId exists. This may become a minor problem.
   */
  static async checkInput(data: ReportDocument) {
    if (!data.uid) throw ERROR_EMPTY_UID;
    if (!data.target) throw ERROR_EMPTY_TARGET;
    if (this.targets.includes(data.target) == false) throw ERROR_WRONG_TARGET;
    if (!data.targetId) throw ERROR_EMPTY_TARGET_ID;
    if (typeof data.reason === void 0) throw ERROR_EMPTY_REASON;
  }

  static getReportId(data: ReportDocument) {
    return data.target + "-" + data.targetId + "-" + data.uid;
  }
  /**
   * Create a report
   */
  static async create(data: ReportDocument): Promise<ReportDocument> {
    await this.checkInput(data);

    const id = this.getReportId(data);
    const report = await this.get(id);
    if (report != null) throw ERROR_ALREADY_REPORTED;

    data.timestamp = Utils.getTimestamp();

    await Ref.reportDoc(id).set(data);
    const doc = await this.get(id);
    if (doc === null) {
      throw ERROR_FAILED_TO_CREATE_REPORT;
    }
    return doc;
  }

  static async get(id: string): Promise<null | ReportDocument> {
    const snapshot = await Ref.reportDoc(id).get();
    if (snapshot.exists) {
      const report = snapshot.data() as ReportDocument;
      report.id = id;
      return report;
    }
    return null;
  }
}
