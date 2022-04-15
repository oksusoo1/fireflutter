import * as admin from "firebase-admin";
import {
  ERROR_EMPTY_COMPANY_NAME,
  ERROR_EMPTY_ID,
  ERROR_EMPTY_PROVINCE,
  ERROR_JOB_NOT_EXIST,
  ERROR_NOT_YOUR_JOB,
} from "../defines";
export class Job {
  static async create(data: any): Promise<any> {
    if (typeof data.companyName === "undefined") {
      throw ERROR_EMPTY_COMPANY_NAME;
    }
    if (typeof data.siNm === "undefined") {
      throw ERROR_EMPTY_PROVINCE;
    }

    if (typeof data.files === void 0) data.files = [];

    data.createdAt = admin.firestore.FieldValue.serverTimestamp();
    data.updatedAt = admin.firestore.FieldValue.serverTimestamp();
    const ref = await admin.firestore().collection("jobs").add(data);
    return this.get(ref.id);
  }
  static async update(data: any): Promise<any> {
    if (!data.id) throw ERROR_EMPTY_ID;
    const job = await this.get(data.id);
    if (job === null) throw ERROR_JOB_NOT_EXIST;
    if (job.uid !== data.uid) throw ERROR_NOT_YOUR_JOB;

    const id = data.id;
    delete data.id;

    // updatedAt
    data.updatedAt = admin.firestore.FieldValue.serverTimestamp();

    await admin.firestore().collection("jobs").doc(id).update(data);
    return this.get(id);
  }

  static async get(id: string): Promise<any> {
    if (typeof id === void 0 || id.trim() === "") throw ERROR_EMPTY_ID;
    const ref = admin.firestore().collection("jobs").doc(id);
    // return the document object of newly created post.
    const snapshot = await ref.get();
    if (snapshot.exists === false) throw ERROR_JOB_NOT_EXIST;
    // Post create success
    const job = snapshot.data() as any;
    job.id = ref.id;

    return job;
  }
}
