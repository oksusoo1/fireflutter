/**
 *
 */
export interface UserDocument {
  id: string;
  isAdmin: boolean;
  lastName: string;
  firstName: string;
  middleName: string;
  nickname: string;
  registeredAt: number;
  updatedAt: number;
  point: number;
  level: number;

  photoUrl: string;
  gender: string;
  birthday: number;

  password?: string;
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
