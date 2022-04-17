export interface PointHistory {
  key?: string;
  eventName: string;
  point: number;
  timestamp: number;
  reason?: string;
}
export class EventName {
  static register = "register";
  static signIn = "signIn";
  static postCreate = "postCreate";
  static commentCreate = "commentCreate";
}

export class ExtraReason {
  static jobCreate = "jobCreate";
}

export interface ExtraPointDocument {
  key?: string;
  point: number;
  timestamp: number;
  reason: string;
}
