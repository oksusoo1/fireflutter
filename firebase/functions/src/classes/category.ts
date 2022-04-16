import { CategoryDocument } from "../interfaces/forum.interface";
import { Ref } from "./ref";

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
