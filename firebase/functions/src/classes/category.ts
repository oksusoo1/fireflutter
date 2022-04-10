import { Ref } from "./ref";

export class Category {
  static async exists(id: string): Promise<boolean> {
    const snapshot = await Ref.categoryDoc(id).get();
    if (snapshot.exists && snapshot.data()) {
      return true;
    } else {
      return false;
    }
  }
}
