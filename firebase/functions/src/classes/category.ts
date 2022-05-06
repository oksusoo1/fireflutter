import { CategoryDocument } from "../interfaces/forum.interface";
import { Ref } from "./ref";
import * as admin from "firebase-admin";

export class Category {
  /**
   * Create a category for test
   *
   * @param id category id
   * @return reference of the cateogry
   *
   * ! TODO - admin permission check.
   */
  static async create(data: { id: string; point: number }) {
    // delete data.id; // call-by-reference. it will causes error after this method.
    const doc = {
      title: data.id,
      point: data.point ?? 0,
      order: 0,
    } as any;
    await Ref.categoryDoc(data.id).set(doc, { merge: true });
    return this.get(data.id);
  }

  /**
   * Returns category
   * @param id category id
   * @returns category data or null
   */
  static async get(id: string): Promise<CategoryDocument | null> {
    const snapshot = await Ref.categoryDoc(id).get();
    if (snapshot.exists) {
      const data = snapshot.data() as CategoryDocument;
      data.id = id;
      return data;
    } else {
      return null;
    }
  }

  static async gets(categoryGroup?: string): Promise<CategoryDocument[]> {
    let q: admin.firestore.Query = Ref.categoryCol;
    let querySnapshot: FirebaseFirestore.QuerySnapshot<FirebaseFirestore.DocumentData> | null;
    if (categoryGroup != null) {
      q = q.where("categoryGroup", "==", categoryGroup);
    }
    querySnapshot = await q.orderBy("order", "desc").get();

    if (querySnapshot.size == 0) return [];

    const _categories: Array<CategoryDocument> = [];

    querySnapshot.forEach((doc) =>
      _categories.push({ id: doc.id, ...doc.data() } as CategoryDocument)
    );

    return _categories;
  }

  /**
   * Returns true if category exists.
   * @param id category id
   * @returns boolean
   */
  static async exists(id: string): Promise<boolean> {
    const category = await this.get(id);
    return category != null;
  }
}
