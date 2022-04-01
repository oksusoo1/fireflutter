export interface QuizResult {
  quizId: string;
  answer: string;
  result: boolean;
}

export interface QuizAnswer {
  [quizId: string]: {
    answer: string;
  };
}
