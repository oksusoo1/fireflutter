import {
  ERROR_ALREADY_REPORTED,
  ERROR_EMPTY_REPORTEE_UID,
  ERROR_EMPTY_TARGET,
  ERROR_EMPTY_TARGET_ID,
  ERROR_EMPTY_UID,
} from "../defines";
import { Ref } from "./ref";

// uid is the reporter id
interface ReportDocument {
  id?: string;
  target: "post" | "comment" | "user";
  targetId: string;
  uid: string;
  reporteeUid: string;
  reason: string;
}

export class Report {
  /**
   * Create a report
   */
  static async create(data: ReportDocument) {
    if (!data.uid) throw ERROR_EMPTY_UID;
    if (!data.target) throw ERROR_EMPTY_TARGET;
    if (!data.targetId) throw ERROR_EMPTY_TARGET_ID;
    if (!data.reporteeUid) throw ERROR_EMPTY_REPORTEE_UID;

    const id = data.target + "-" + data.targetId + "-" + data.uid;
    const report = await this.get(id);
    if (report != null) throw ERROR_ALREADY_REPORTED;

    await Ref.reportDoc(id).set(data);
    return this.get(id);
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
