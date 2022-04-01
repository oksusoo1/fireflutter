/**
 *
 */
export class UserModel {
  id = "";
  isAdmin = false;
  lastName = "";
  firstName = "";
  middleName = "";
  nickname = "";
  registeredAt = 0;
  updatedAt = 0;
  point = 0;

  photoUrl = "";
  gender = "";
  birthday = 0;

  password = "";

  static fromJson(doc: UserModel, id: string): UserModel {
    const o = new UserModel();
    o.id = id;
    o.isAdmin = doc.isAdmin ?? false;
    o.lastName = doc.lastName ?? "";
    o.firstName = doc.firstName ?? "";
    o.middleName = doc.middleName ?? "";
    o.nickname = doc.nickname ?? "";
    o.photoUrl = doc.photoUrl ?? "";
    o.gender = doc.gender ?? "";
    o.birthday = doc.birthday ?? 0;
    o.registeredAt = doc.registeredAt ?? 0;
    o.updatedAt = doc.updatedAt ?? 0;
    o.point = doc.point ?? 0;

    // ! warning. this is very week password, but it is difficult to guess.
    o.password = this.generatePassword(o);

    return o;
  }

  static generatePassword(doc: UserModel) {
    return doc.id + "-" + doc.registeredAt + "-" + doc.updatedAt + "-" + doc.point;
  }
}

export interface UserCreate {
  firstName?: string;
  middleName?: string;
  lastName?: string;
  nickname?: string;
  gender?: string;
  registeredAt?: number;
  photoUrl?: string;
  updatedAt?: number;
  birthday?: number;
}
